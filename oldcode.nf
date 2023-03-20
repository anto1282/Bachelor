//SAMPLERATES_ch = Channel.fromList([0.05,0.1,0.15,0.2,0.25]).flatten()
//SUBSAMPLEFORCOVERAGE(NoEUReads_ch,SAMPLERATES_ch,params.sampleseed)
//.set { READS_SUBS_ch }
//ASSEMBLY_ch_COVERAGE = SPADES(READS_SUBS_ch,OFFSET)
//SAMPLERATE_BEST = COVERAGE(ASSEMBLY_ch_COVERAGE).toInteger().collect()
// SAMPLERATE_BEST.view()
//SAMPLERATE_BEST.flatten().max().view()
//SAMPLESEEDS_ch = Channel.fromList([1,2,3,4,5]).flatten() // MAKE python script to create list
//SUBSAMPLEFORN50(NoEUReads_ch, SAMPLERATE_BEST.flatten().max(), SAMPLESEEDS_ch)
//.set { READS_ch_N50 }