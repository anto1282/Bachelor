#!/usr/bin/env python3

#Create a script that runs pharokkas imager tool

#Take the extracted viruses from virextractor.py
#Find the corresponding viruses in the iphop results
#Show length of phage and completeness using checkv
#Add a picture of the assembled phage

import sys


outputfilename = str(sys.argv[1])
predictedviruses = str(sys.argv[2])
iphoppredictions = str(sys.argv[3])
checkvpredictions = str(sys.argv[4])
assemblystats = str(sys.argv[5])
SRA_nr = str(sys.argv[6])

virusdict = dict()
with open(predictedviruses, 'r') as fasta_file:
	# Extracts sequence and header from file and adds it to the virusdict
	header = ''
	sequence = ''
	for line in fasta_file:
		
		if line.startswith('>'):
			if header != '':
				virusdict[header] = []
				virusdict[header].append(sequence)
				sequence = ''
			header = line[1:].strip()
		else:
			sequence += line 
	virusdict[header] = [sequence]
for key in virusdict:
	print("Contigs in predicted viruses file:", key)

if (iphoppredictions != "NOIPHOP"):
	#Extracts taxonomic information from the IPHOP results file and appends it to the virusdict
	with open(iphoppredictions, 'r') as file:
		linecount = 0 
		for line in file:
			if linecount > 0:
				line = line.strip().split(',')
				hostgenus = line[2].split(";")
				hostgenus_formatted = ""
				
				for element in hostgenus:
					
					hostgenus_formatted += element[3:] + "; "
				#Creates set with the host genus information
				if len(virusdict[line[0]]) == 1:
					virusdict[line[0]].append({hostgenus_formatted.strip("; ")})
				
				else:
					virusdict[line[0]][1].add(hostgenus_formatted.strip("; "))
				
			linecount += 1
	for key in virusdict:
		if len(virusdict[key]) == 1:
			virusdict[key].append(("No taxonomic information found for this contig"))
else:
	for key in virusdict:
		virusdict[key].append("No taxonomic information, since IPHOP wasn't run")

with open(checkvpredictions, 'r') as file:
	#Extracts phage completeness score from the checkV file as well as the length of the contig
	linecount = 0 
	for line in file:
		if linecount > 0:
			line = line.split()
			try:
				
				contiglength = line[1]
				completenessscore = line[4]
				virusdict[line[0]].append(contiglength) # Contig length
				#Completeness
				if completenessscore != "NA":
					virusdict[line[0]].append(round(float(line[4]),2))
				else:
					virusdict[line[0]].append("Not Available")
			except KeyError as error:
				print("KeyError: Contig name found in CheckV file, but not among predicted viruses found in dictionary")
				print("Key:", line[0])
				sys.exit(1)
		linecount += 1

assemblystatistics = ""
with open(assemblystats,'r') as file:
	ACGTflag = False
	mainflag = False
	statsflag = False
	for line in file:
		if line.startswith("A"):
			linesplit = line.strip().split()
			line = """
			<table>
				<tr>
			"""
			for elem in linesplit:
				line += "<th>" + elem + "</th>"
			line += """</tr>
			"""
			ACGTflag = True
		elif ACGTflag:
			linesplit = line.strip().split()
			line = """<tr>
			"""
			for elem in linesplit:
				line += "<td>" + elem + "</td>"
			line += """
				</tr>
			</table>"""
			ACGTflag = False
			
		elif line.startswith("Main") and not mainflag :
			mainflag = True
			linesplit = line.strip().split(":")
			line = """
			<table>
				<tr>
			"""
			for elem in linesplit:
				line += "<td>" + elem + "</td>"
			line += """</tr>
			"""
		elif line.startswith("%") and mainflag:
			
			linesplit = line.strip().split(":")
			line = "<tr>"
			for elem in linesplit:
				line += "<td>" + elem + "</td>"
			line += """
				</tr>
			</table>"""
			mainflag = False

		elif mainflag:
			linesplit = line.strip().split(":")
			line = "<tr>"
			for elem in linesplit:
				line += "<td>" + elem + "</td>"
			line += """</tr>
			"""
		elif line.startswith("Minimum"):
			statsflag = True
			linesplit = line.strip().split()
			line = """
			<table>
				<tr>
			"""
			for elem in linesplit:
				line += "<th>" + elem + "</th>"
			line += "</tr>"
		elif line.startswith("Scaffold") or line.startswith("Length"):
			linesplit = line.strip().split()
			line = "<tr>"
			for elem in linesplit:
				line += "<th>" + elem + "</th>"
			line += """</tr>
			"""
		
		elif statsflag and "KB" in line and line.split()[0] == "25":
			linesplit = line.strip().split()
			line = "<tr>" + "<td>" + ' '.join(linesplit[0:2]) + "</td>"
			for elem in linesplit[2:]:
				line += "<td>" + elem + "</td>"
			line += """
					</tr>
				</table>
				"""
			statsflag = False
		
		elif statsflag and "KB" in line:
			linesplit = line.strip().split()
			line = "<tr>" + "<td>" + ' '.join(linesplit[0:2]) + "</td>"
			for elem in linesplit[2:]:
				line += "<td>" + elem + "</td>"
			line += """
				</tr>

				"""
		elif statsflag:
			linesplit = line.strip().split()
			line = "<tr>"
			for elem in linesplit:
				line += "<td>" + elem + "</td>"
			line += """
				</tr>

				"""
		#print(line)
		



		assemblystatistics += line
	

webpage = f"""
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {{font-family: Arial;}}

/* Style the tab */
.tab {{
  overflow: hidden;
  border: 1px solid #ccc;
  background-color: #f1f1f1;
}}

/* Style the buttons inside the tab */
.tab button {{
  background-color: inherit;
  float: left;
  border: none;
  outline: none;
  cursor: pointer;
  padding: 14px 16px;
  transition: 0.3s;
  font-size: 17px;
}}

/* Change background color of buttons on hover */
.tab button:hover {{
  background-color: #ddd;
}}

/* Create an active/current tablink class */
.tab button.active {{
  background-color: #ccc;
}}

/* Style the tab content */
.tabcontent {{
  display: none;
  padding: 6px 12px;
  border: 1px solid #ccc;
  border-top: none;
}}

/* Centering the pictures on the page*/
.center {{
  display: block;
  margin-left: auto;
  margin-right: auto;
  width: 50%;
}}
</style>
</head>
<body>

<h1>NPhAnToM Pipeline Results</h1>
<h2>{SRA_nr}</h2>
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
	<img class="center" src="{}" alt="Illustration of annotated phage">
	<p><strong>{}</strong></p>
	<p>{}</p>
	
</div>
"""

statisticstabs = """
<div id="{}" class="tabcontent">
	<h1>{}</h1>
	{}
	
</div>
"""



# Generating the HTML file with a tab for each phage and a statistics tab
buttonstring = """<div class="tab">"""
tabstring = ""



with open(outputfilename, 'w') as f:  
	f.write(webpage)

	#Creating a tab for statistics
	buttonstring += opentab.format("Statistics","Assembly Statistics")

	tabstring += statisticstabs.format("Statistics","Statistics of the assembly", assemblystatistics)
	

	
	buttonstring += ("""<button onclick="window.location.href = 'fastp.html';">Fastp output</button>""")
	buttonstring += ("""<button onclick="window.location.href = '{}_1_trimmed_fastqc.html';">Quality of Read1</button>""").format(SRA_nr)
	buttonstring += ("""<button onclick="window.location.href = '{}_2_trimmed_fastqc.html';">Quality of Read2</button>""").format(SRA_nr)

	#Creating the tabs for the phages
	for key in virusdict:
		print("Contig info to HTML:", key)
		#print(virusdict[key])
		#if (len(virusdict[key]) == 4):
		host = (virusdict[key][1])
		print(host)
		length = (virusdict[key][2])
		completeness = (virusdict[key][3])
		print(length, completeness)
		picturepath = key + ".png"
		DNAtext = "Phage DNA:"
		contig = virusdict[key][0]
		buttonstring += (opentab.format(key,key))
		tabstring += tabs.format(key,key,host,length, completeness, picturepath,DNAtext,contig.replace("\n","<br>"))
	buttonstring += "</div>"
	f.write(buttonstring)
	f.write(tabstring)
	f.write(bottomofpage)
    

