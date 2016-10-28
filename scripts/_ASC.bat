for /r %%1 in (.) do if exist "%%1\*.nss" f:\asc -aglo -v1.69 -y "%%1\*.nss"

::pause
