process GRIDLINE_FORGE_DUPLICATEFINDER {
    tag "${meta.id}"
    label 'process_single'

    container "ghcr.io/flowuenne/gridline-forge:main"

    input:
    tuple val(meta), path(spot_table)

    output:
    tuple val(meta), path("*_markedDups.txt"), emit: marked_dups_spots
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    gridline-forge duplicate-finder \\
        ${spot_table} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gridline_forge: \$(gridline-forge --version | sed 's/gridline-forge //')
    END_VERSIONS
    """

    stub:
    """
    touch ${spot_table.baseName}_markedDups.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gridline_forge: \$(gridline-forge --version | sed 's/gridline-forge //')
    END_VERSIONS
    """
}
