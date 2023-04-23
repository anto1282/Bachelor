#!/usr/bin/env python3
    
import sys

viralcontigs = sys.argv[1]

with open(viralcontigs, 'r') as infile:
        header = ''
        sequence = ''
        for line in infile:
            line = line.strip()
            if line.startswith('>'):
                if header != '':
                    output_file = header + '.fasta'
                    with open(output_file, 'w') as outfile:
                        outfile.write('>' + header + '\n' + sequence + '\n')
                    sequence = ''
                header = line[1:]
            else:
                sequence += line
        output_file = header + '.fasta'
        with open(output_file, 'w') as outfile:
            outfile.write('>' + header + '\n' + sequence + '\n')