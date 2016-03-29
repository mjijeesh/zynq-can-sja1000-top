	/* load uEnv.txt before boot (copied from U-Boot default config) */ \
	"loadbootenv_addr=0x2000000\0" \
	"bootenv=uEnv.txt\0" \
	"loadbootenv=load mmc 0 ${loadbootenv_addr} ${bootenv}\0" \
	"importbootenv=echo Importing environment from SD ...; " "env import -t ${loadbootenv_addr} $filesize\0" \
	"sd_uEnvtxt_existence_test=test -e mmc 0 /uEnv.txt\0" \
	"preboot=if env run sd_uEnvtxt_existence_test; " "then if env run loadbootenv; " "then env run importbootenv; " "fi; " "fi; \0" \
	/* end of custom env */ \
