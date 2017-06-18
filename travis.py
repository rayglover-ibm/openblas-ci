import platform

from collections import namedtuple
from plumbum import local, FG
from plumbum.cmd import make

Job = namedtuple("Job", "TOOLCHAIN TARGET ARCH INTERFACE64 BINARY")

jobs = [
    Job(TOOLCHAIN='gcc', TARGET='NEHALEM', ARCH='x86-64', INTERFACE64='1', BINARY='64'),
    Job(TOOLCHAIN='gcc', TARGET='NEHALEM', ARCH='x86',    INTERFACE64='0', BINARY='32')
]

with local.cwd(local.cwd / "OpenBLAS"):
    for job in jobs:
        with local.env(CC=job.TOOLCHAIN):
            make[
                '-j4',
                'TARGET={0}'.format(job.TARGET),
                'USE_THREAD=0', 'NO_LAPACK=1', 'NO_LAPACKE=1', 'ONLY_CBLAS=1',
                'INTERFACE64={0}'.format(job.INTERFACE64),
                'BINARY={0}'.format(job.BINARY)] & FG
            
            make['PREFIX="../opt/{0}/{1}/{2}/{3}"'.format(
                    platform.system().lower(), job.TOOLCHAIN, job.TARGET, job.ARCH), 'install'] & FG

            make['clean'] & FG
