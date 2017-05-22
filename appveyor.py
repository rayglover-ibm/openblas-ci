import platform

from collections import namedtuple
from plumbum import local, FG

mingw32 = 'C:/mingw-w64/i686-6.3.0-posix-dwarf-rt_v5-rev1/mingw32/bin'
mingw64 = 'C:/mingw-w64/x86_64-6.3.0-posix-seh-rt_v5-rev1/mingw64/bin'

Job = namedtuple("Job", "TOOLCHAIN TARGET ARCH INTERFACE64 BINARY")

jobs = [
    Job(TOOLCHAIN='mingw', TARGET='NEHALEM', ARCH='x86-64', INTERFACE64='0', BINARY='64'),
    Job(TOOLCHAIN='mingw', TARGET='NEHALEM', ARCH='x86',    INTERFACE64='0', BINARY='32')
]

with local.cwd(local.cwd / 'OpenBLAS'):
    for job in jobs:
        with local.env(PATH=(mingw64 if job.ARCH == 'x86-64' else mingw32) + ';C:/msys64/usr/bin/'):
            make = local.get('make')

            make['TARGET={0}'.format(job.TARGET),
                'NUM_THREADS=1', 'NO_LAPACK=1', 'NO_LAPACKE=1', 'ONLY_CBLAS=1',
                'INTERFACE64={0}'.format(job.INTERFACE64),
                'BINARY={0}'.format(job.BINARY)] & FG

            make['PREFIX=../opt/{0}/{1}/{2}/{3}'.format(
                    platform.system().lower(), job.TOOLCHAIN, job.TARGET, job.ARCH), 'install'] & FG

            make['clean'] & FG
