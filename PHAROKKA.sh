





"singularity pull docker://quay.io/biocontainers/pharokka:1.3.0--hdfd78af_0 -d "
singularity run ${singularity.cacheDir}/pharokka:1.3.0--hdfd78af_0.img -i ${viralcontigs} -o pharokka_${pair_id} -f -t ${task.cpus} -d ${params.phaDB} -g prodigal -m
