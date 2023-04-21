#!/usr/bin/env python3

#Create a script that runs pharokkas imager tool

#Take the extracted viruses from virextractor.py
#Find the corresponding viruses in the iphop results
#Show length of phage and completeness using checkv
#Add a picture of the assembled phage

import sys, os


outputfilename = str(sys.argv[1])
predictedviruses = str(sys.argv[2])
iphoppredictions = str(sys.argv[3])
checkvpredictions = str(sys.argv[4])
assemblystats = str(sys.argv[5])
SRA_nr = str(sys.argv[6])

virusdict = dict()
with open(predictedviruses, 'r') as fasta_file:
	header = ''
	sequence = ''
	for line in fasta_file:
		
		if line.startswith('>'):
			if header.strip() != '':
				virusdict[header.strip()] = []
				virusdict[header.strip()].append(sequence)
				sequence = ''
			header = line[1:]
		else:
			sequence += line 
	virusdict[header] = [sequence]

#iphopdict = dict()

if (iphoppredictions != "NOIPHOP"):
	with open(iphoppredictions, 'r') as file:
		linecount = 0 
		for line in file:
			if linecount > 0:
				line = line.split(',')
				hostgenus = line[2].split(";")
				hostgenus_formatted = ""
				for element in hostgenus:
					
					hostgenus_formatted += element[3:] + "; "
				
				virusdict[line[0]].append(hostgenus_formatted.strip("; "))
			linecount += 1
else:
	for key in virusdict:
		virusdict[key].append("No taxonomic information, since IPHOP wasn't run")

with open(checkvpredictions, 'r') as file:
    linecount = 0 
    for line in file:
        if linecount > 0:
            line = line.split()
            virusdict[line[0]].append(line[1])
	    	virusdict[line[0]].append(round(float(line[4]),2))
        linecount += 1

assemblystatistics = ""
with open(assemblystats,'r') as file:
	for line in file:
		assemblystatistics += line


webpage = """
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {font-family: Arial;}

/* Style the tab */
.tab {
  overflow: hidden;
  border: 1px solid #ccc;
  background-color: #f1f1f1;
}

/* Style the buttons inside the tab */
.tab button {
  background-color: inherit;
  float: left;
  border: none;
  outline: none;
  cursor: pointer;
  padding: 14px 16px;
  transition: 0.3s;
  font-size: 17px;
}

/* Change background color of buttons on hover */
.tab button:hover {
  background-color: #ddd;
}

/* Create an active/current tablink class */
.tab button.active {
  background-color: #ccc;
}

/* Style the tab content */
.tabcontent {
  display: none;
  padding: 6px 12px;
  border: 1px solid #ccc;
  border-top: none;
}
</style>
</head>
<body>

<h1>NPhAnToM Pipeline Results</h1>
<p>Click on the buttons inside the tabbed menu to see the annotated phages:</p>



"""



bottomofpage = """
<script>
function openPhage(evt, phageName) {
  var i, tabcontent, tablinks;
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
  document.getElementById(phageName).style.display = "block";
  evt.currentTarget.className += " active";
}
</script>
   
</body>
</html> 
"""

opentab = """

  	<button class="tablinks" onclick="openPhage(event, '{}')">{}</button>

"""

tabs = """
<div id="{}" class="tabcontent">
	<h1>{}</h1>
	<p><strong>Host taxonomy:</strong> {}</p>
    <p><strong>Length:</strong> {} bp</p>
    <p><strong>Phage completeness (from CheckV):</strong> {} %</p>
	<p><strong>Illustration of annotated phage:</strong></p>
	<img class="picture" src="{}" alt="Illustration of annotated phage">
	<p><strong>{}</strong></p>
	<p>{}</p>
	
</div>
"""

statisticstabs = """
<div id="{}" class="tabcontent">
	<h1>{}</h1>
	<p>{}</p>
	
</div>
"""



# Generating the HTML file with a tab for each phage and a statistics tab
buttonstring = """<div class="tab">"""
tabstring = """"""

with open(outputfilename, 'w') as f:  
	f.write(webpage)

	#Creating a tab for statistics
	buttonstring += opentab.format("Statistics","Assembly Statistics")

	tabstring += statisticstabs.format("Statistics","Statistics of the assembly", assemblystatistics)
	

	
	buttonstring += ("""<button onclick="window.location.href = 'fastp.html';">Fastp output</button>'""")
	buttonstring += ("""<button onclick="window.location.href = '{}_1_trimmed_fastqc.html';">Quality of Read1</button>'""").format(SRA_nr)
	buttonstring += ("""<button onclick="window.location.href = '{}_2_trimmed_fastqc.html';">Quality of Read2</button>'""").format(SRA_nr)

	#Creating the tabs for the phages
	for key in virusdict:
		print(key)
		host = (virusdict[key][1])
		length = (virusdict[key][2])
		completeness = virusdict[key][3]
		picturepath = key + ".png"
		DNAtext = "Phage DNA:"
		contig = virusdict[key][0]
		buttonstring += (opentab.format(key,key))
		tabstring += tabs.format(key,key,host,length, completeness, picturepath,DNAtext,contig)
	buttonstring += "</div>"
	f.write(buttonstring)
	f.write(tabstring)
	f.write(bottomofpage)
    
#Quality tab
