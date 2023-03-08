def coverageFinderAverage(read1,read2,directory,contigfilepath):
    print("Finding maximum coverage among assemblies which are larger than half of the size of the largest contig.")
    contigs = contigfilepath
    coveragestats = "coveragestats.txt"
    subprocess.run(["conda","run","-n","QC","bbmap.sh","ref=" + contigs,"in=" + read1,"in2=" + read2,"out=coverage_mapping.sam","nodisk=t","fast=t","covstats="+coveragestats],cwd = directory)
    print("Finished")
    linecount = 0
    sumcoverage = 0
    longestcontiglength = None
    with open(coveragestats,'r') as covfile:
        for line in covfile:
            linesplit = line.split()
            if linecount == 1:
                print(line)
                longestcontiglength = float(linesplit[2])
                sumcoverage = float(linesplit[1])
            elif linecount > 1:
                if float(linesplit[2]) > longestcontiglength * 0.7:
                    print(line)
                    sumcoverage += float(linesplit[1])
                else:
                    break
                
            linecount += 1      
    averagecoverage = sumcoverage / linecount - 1
    return averagecoverage, coveragestats

