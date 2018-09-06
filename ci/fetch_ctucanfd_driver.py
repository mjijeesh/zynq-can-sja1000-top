"""
Download ctucanfd.ko linux driver for the given SHA commit.
Usage: ./fetch_ctucanfd_driver.py SHA

The driver will be saved as ./ctucanfd.ko.
Regtest utility will be saved as ./regtest.
"""

from requests import get
import sys

# ctu can fd commit sha
sha = sys.argv[1]

base = 'https://gitlab.fel.cvut.cz/api/v4/projects/6719'


def filter_job(jobs, name):
    return filter(jobs, lambda j: j.status == 'success' and j.name == name)[0]


pipelines = get(base+"/pipelines?sha=${sha}&status=success").json()
pid = pipelines[0].id

jobs = get(base+'/pipelines/{pid}/jobs'.format(pid=pid)).json()
job_id = filter_job(jobs, 'build_linux_driver').id

content = get("{}/jobs/${job_id}/artifacts/driver/linux/ctucanfd.ko"
              .format(base, job_id=job_id)
             ).content()
with open('ctucanfd.ko', 'wb') as f:
    f.write(content)

# regtest
job_id = filter_job(jobs, 'build_driver').id

content = get("{}/jobs/${job_id}/artifacts/driver/regtest"
              .format(base, job_id=job_id)
             ).content()
with open('regtest', 'wb') as f:
    f.write(content)
