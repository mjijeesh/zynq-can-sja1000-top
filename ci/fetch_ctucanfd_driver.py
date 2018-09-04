"""
Download ctucanfd.ko linux driver for the given SHA commit.
Usage: ./fetch_ctucanfd_driver.py SHA

The driver will be saved as ./ctucanfd.ko
"""

from requests import get
import sys

# ctu can fd commit sha
sha = sys.argv[1]

base = 'https://gitlab.fel.cvut.cz/api/v4/projects/6719'

pipelines = get(base+"/pipelines?sha=${sha}&status=success").json()
pid = pipelines[0].id

jobs = get(base+'/pipelines/{pid}/jobs'.format(pid=pid)).json()
jobs = filter(jobs, lambda j: j.status == 'success' and j.name == 'build_linux_driver')
job_id = jobs[0]

content = get(base+"/jobs/${job_id}/artifacts/driver/linux/ctucanfd.ko".format(job_id=job_id)).content()
with open('ctucanfd.ko', 'wb') as f:
    f.write(content)
