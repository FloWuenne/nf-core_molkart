process GRIDLINE_FORGE {
    tag "$meta.id"
    label 'process_low'

    container "ghcr.io/flowuenne/gridline-forge:main"

    input:
    tuple val(meta), path(panorama)

    output:
    tuple val(meta), path("*_gridfilled.{tif,tiff}"), emit: tiff
    path "versions.yml"                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    export RAYON_NUM_THREADS=${task.cpus}

    gridline-forge \\
        $panorama \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gridline_forge: \$(gridline-forge --version | sed 's/gridline-forge //')
    END_VERSIONS
    """

    stub:
    """
    touch ${panorama.baseName}_gridfilled.tiff

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gridline_forge: \$(gridline-forge --version | sed 's/gridline-forge //')
    END_VERSIONS
    """
}
