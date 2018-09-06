#
# Based on python_kmsg from maliubiao<maliubiao@gmail.com>, MIT licensed
#

import os
import fcntl
import errno

# log level
(LOG_EMERG, LOG_ALERT, LOG_CRIT, LOG_ERR, LOG_WARN,
    LOG_NOTICE, LOG_INFO, LOG_DEBUG) = range(8)

# facility codes
(LOG_KERN, LOG_USER, LOG_MAIL, LOG_DAEMON, LOG_AUTH, LOG_SYSLOG,
    LOG_LPR, LOG_NEWS, LOG_UUCP, LOG_CRON, LOG_AUTHPRIV,
    LOG_FTP) = [x << 3 for x in range(12)]

log_level_dict = {
    LOG_EMERG: ("emerg", "system is unusable"),
    LOG_ALERT: ("alert", "action must be taken immediately"),
    LOG_CRIT: ("crit", "critical conditions"),
    LOG_ERR: ("err", "error conditions"),
    LOG_WARN: ("warn", "warning conditions"),
    LOG_NOTICE: ("notice", "normal but significant condition"),
    LOG_INFO: ("info", "information"),
    LOG_DEBUG: ("debug", "debug-level message")
}

log_dict = dict([(y[0], x) for x, y in log_level_dict.items()])


facility_codes_dict = {
    LOG_KERN: ("kernel", "kernel messages"),
    LOG_USER: ("user", "random user-level messages"),
    LOG_MAIL: ("mail", "mail system"),
    LOG_DAEMON: ("daemon", "system daemons"),
    LOG_AUTH: ("auth", "security/authorization messages"),
    LOG_SYSLOG: ("syslog", "messages generated internally by syslogd"),
    LOG_LPR: ("lpr", "line printer subsystem"),
    LOG_NEWS: ("news", "network news subsystem"),
    LOG_UUCP: ("uucp", "UUCP subsystem"),
    LOG_CRON: ("cron", "clock daemon"),
    LOG_AUTHPRIV: ("authpriv", "security/authorization messages (private)"),
    LOG_FTP: ("ftp", "ftp daemon")
}

fac_dict = dict([(y[0], x) for x, y in facility_codes_dict.items()])


LOG_NO_PRI = 0x10

BUF_SIZE = 512
# bits 0-2-> pri,  high bits -> facility


def log_pri(p):
    return p & 0x07


def log_fac(p):
    return (p & 0x03f8) >> 3


def log_make_pri(fac, pri):
    return fac | pri


class ObjectLikeDict(dict):
    def __getattr__(self, name):
        return self[name]


def parse_msg(msg):
    '''
    /dev/kmsg record format:
        faclev,seqnum,timestamp[optional,..];message\n
         TAGNAME=value
         ...
    '''
    # msg header and body
    header, msg = msg.split(';', 1)
    # msg header
    facpri, seq, time, *other = header.split(",")
    facpri = int(facpri)
    seq = int(seq)
    time = int(time)
    # tags
    msg, *tags = msg.split('\n')
    tags = dict(tag[1:].split('=', 1) for tag in tags if tag)
    return ObjectLikeDict({
        "fac": log_fac(facpri),
        "pri": log_pri(facpri),
        "seqnum": seq,
        "timestamp": time,
        "other": other,
        "msg": msg,
        "tags": tags
    })


class Kmsg:
    def __init__(self, seek_to_end=False, base_timestamp=False):
        self.base_timestamp = base_timestamp
        self.file = open("/dev/kmsg", "rb", buffering=0)
        fcntl.fcntl(self.file.fileno(), fcntl.F_SETFL, os.O_NONBLOCK)
        if seek_to_end:
            self.seek_to_end()

    def close(self):
        self.file.close()
        self.file = None

    def seek_to_end(self):
        os.lseek(self.file.fileno(), 0, os.SEEK_END)

    def reset_base_timestamp(self, base_timestamp=None):
        self.base_timestamp = base_timestamp

    def messages(self):
        while True:
            try:
                msg = self.file.read(BUF_SIZE)
            except OSError as e:
                if e.errno == errno.EAGAIN:
                    break
                else:
                    raise e
            if msg is None:
                break
            msg = parse_msg(msg.decode('latin1'))
            if self.base_timestamp is None:
                self.base_timestamp = msg['timestamp']
            if self.base_timestamp is not False:
                msg['timestamp'] -= self.base_timestamp
            yield msg


if __name__ == '__main__':
    import selectors
    from pprint import pprint
    kmsg = Kmsg(seek_to_end=False, base_timestamp=None)
    sel = selectors.DefaultSelector()
    def print_all():
        n = 0
        for msg in kmsg.messages():
            pprint(msg)
            n += 1
        print(n)
    sel.register(kmsg.file, selectors.EVENT_READ, print_all)
    while True:
        for k, events in sel.select():
            k.data()
