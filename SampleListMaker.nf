

process SAMPLELISTMAKER{
    input:
    val fromVal
    val toVal
    val byVal

    output:
    val sampleRate
    
    script:
    """
    python3 SampleList.py ${fromVal} ${toVal} ${byVal}
    """
}