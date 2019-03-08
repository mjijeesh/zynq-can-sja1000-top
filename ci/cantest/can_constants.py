# from enum import IntFlag


class CAN_ERR:  # (IntFlag):
    MASK          = 0x1FFFFFFF

    TX_TIMEOUT    = 0x00000001  # TX timeout (by netdevice driver)
    LOSTARB       = 0x00000002  # lost arbitration    / data[0]
    CRTL          = 0x00000004  # controller problems / data[1]
    PROT          = 0x00000008  # protocol violations / data[2..3]
    TRX           = 0x00000010  # transceiver status  / data[4]
    ACK           = 0x00000020  # received no ACK on transmission
    BUSOFF        = 0x00000040  # bus off
    BUSERROR      = 0x00000080  # bus error (may flood!)
    RESTARTED     = 0x00000100  # controller restarted

    # arbitration lost in bit ... / data[0]
    LOSTARB_UNSPEC    = 0x00  # unspecified
                              # else bit number in bitstream

    # error status of CAN-controller / data[1]
    CRTL_UNSPEC       = 0x00  # unspecified
    CRTL_RX_OVERFLOW  = 0x01  # RX buffer overflow
    CRTL_TX_OVERFLOW  = 0x02  # TX buffer overflow
    CRTL_RX_WARNING   = 0x04  # reached warning level for RX errors
    CRTL_TX_WARNING   = 0x08  # reached warning level for TX errors
    CRTL_RX_PASSIVE   = 0x10  # reached error passive status RX
    CRTL_TX_PASSIVE   = 0x20  # reached error passive status TX
                              # (at least one error counter exceeds
                              # the protocol-defined level of 127)
    CRTL_ACTIVE       = 0x40  # recovered to error active state

    # error in CAN protocol (type) / data[2]
    PROT_UNSPEC       = 0x00  # unspecified
    PROT_BIT          = 0x01  # single bit error
    PROT_FORM         = 0x02  # frame format error
    PROT_STUFF        = 0x04  # bit stuffing error
    PROT_BIT0         = 0x08  # unable to send dominant bit
    PROT_BIT1         = 0x10  # unable to send recessive bit
    PROT_OVERLOAD     = 0x20  # bus overload
    PROT_ACTIVE       = 0x40  # active error announcement
    PROT_TX           = 0x80  # error occurred on transmission

    # error in CAN protocol (location) / data[3]
    PROT_LOC_UNSPEC   = 0x00  # unspecified
    PROT_LOC_SOF      = 0x03  # start of frame
    PROT_LOC_ID28_21  = 0x02  # ID bits 28 - 21 (SFF: 10 - 3)
    PROT_LOC_ID20_18  = 0x06  # ID bits 20 - 18 (SFF: 2 - 0 )
    PROT_LOC_SRTR     = 0x04  # substitute RTR (SFF: RTR)
    PROT_LOC_IDE      = 0x05  # identifier extension
    PROT_LOC_ID17_13  = 0x07  # ID bits 17-13
    PROT_LOC_ID12_05  = 0x0F  # ID bits 12-5
    PROT_LOC_ID04_00  = 0x0E  # ID bits 4-0
    PROT_LOC_RTR      = 0x0C  # RTR
    PROT_LOC_RES1     = 0x0D  # reserved bit 1
    PROT_LOC_RES0     = 0x09  # reserved bit 0
    PROT_LOC_DLC      = 0x0B  # data length code
    PROT_LOC_DATA     = 0x0A  # data section
    PROT_LOC_CRC_SEQ  = 0x08  # CRC sequence
    PROT_LOC_CRC_DEL  = 0x18  # CRC delimiter
    PROT_LOC_ACK      = 0x19  # ACK slot
    PROT_LOC_ACK_DEL  = 0x1B  # ACK delimiter
    PROT_LOC_EOF      = 0x1A  # end of frame
    PROT_LOC_INTERM   = 0x12  # intermission

    # error status of CAN-transceiver / data[4]
    #                                 CANH CANL
    TRX_UNSPEC              = 0x00  # 0000 0000
    TRX_CANH_NO_WIRE        = 0x04  # 0000 0100
    TRX_CANH_SHORT_TO_BAT   = 0x05  # 0000 0101
    TRX_CANH_SHORT_TO_VCC   = 0x06  # 0000 0110
    TRX_CANH_SHORT_TO_GND   = 0x07  # 0000 0111
    TRX_CANL_NO_WIRE        = 0x40  # 0100 0000
    TRX_CANL_SHORT_TO_BAT   = 0x50  # 0101 0000
    TRX_CANL_SHORT_TO_VCC   = 0x60  # 0110 0000
    TRX_CANL_SHORT_TO_GND   = 0x70  # 0111 0000
    TRX_CANL_SHORT_TO_CANH  = 0x80  # 1000 0000

    # controller specific additional information / data[5..7]
