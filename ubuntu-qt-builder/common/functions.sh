function toolchain_name() {
	local prefix=$1
	local tool=$2
	local ver=$3
	echo ${prefix}/${tool}-${ver}
}

function set_gcc_version() {
	local ver=$1
	local dir=/usr/bin
	local dest=${HOME}/bin
	local tools=(gcc g++)

	for i in "${!tools[@]}"; do
		tool=${tools[$i]}
		cmd=$(toolchain_name ${dir} ${tool} ${ver})

		if [ -x ${cmd} ]; then
			ln -s -f ${cmd} ${dest}/${tool}
		fi
	done
}
