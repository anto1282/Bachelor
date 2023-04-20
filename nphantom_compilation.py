#!/usr/bin/env python3


# Create file/folder for each phage with the following information
# Alternatively, an html script that makes a website for each phage

# Statistics file, how much eukaryote we removed


#Create a script that runs pharokkas imager tool


#Take the extracted viruses from virextractor.py
#Find the corresponding viruses in the iphop results
#Add a picture of the assembled phage

import sys, os


outputfilename = str(sys.argv[1])
predictedviruses = str(sys.argv[2])
iphoppredictions = str(sys.argv[3])

virusdict = dict()

with open(predictedviruses,'r') as file:
    phagekey, phagecontig = "", ""
    linecount = 0
    for line in file:
        if line.startswith(">"):
            phagekey = line.strip()
            if linecount > 0:
                virusdict[phagekey[1:]] = phagecontig
            
        
        else:
            phagecontig += line
    
        linecount += 1
    #Adding the last key/value combination to the set
    virusdict[phagekey] = phagecontig
print(virusdict.keys())

iphopdict = dict()
with open(iphoppredictions, 'r') as file:
    linecount = 0 
    for line in file:
        if linecount > 0:
            line = line.split(',')
            iphopdict[line[0]] = line[2]
        linecount += 1



# html_template = '''
# <!DOCTYPE html>
# <html>
# 	<head>
# 		<meta charset="UTF-8">
# 		<title>{}</title>
# 		<style>
# 			body {{
# 				font-family: Arial, sans-serif;
# 			}}
# 			.container {{
# 				margin: 0 auto;
# 				max-width: 800px;
# 			}}
# 			.tab {{
# 				display: none;
# 			}}
# 			.tab.active {{
# 				display: block;
# 			}}
# 			.tab-button {{
# 				background-color: #f2f2f2;
# 				border: none;
# 				color: black;
# 				padding: 10px;
# 				font-size: 16px;
# 				cursor: pointer;
# 			}}
# 			.tab-button.active {{
# 				background-color: #ccc;
# 			}}
# 			.picture {{
# 				max-width: 100%;
# 			}}
# 		</style>
# 	</head>
# 	<body>
# 		<div class="container">
# 			<h1>{}</h1>
# 			<p><strong>Key:</strong> {}</p>
# 			<p><strong>Host:</strong> {}</p>
# 			<p><strong>Picture:</strong></p>
# 			<img class="picture" src="{}" alt="Example Picture">
# 			<p><strong>DNA:</strong> {}</p>
# 			<p><strong>Contig:</strong> {}</p>
# 			<pre>print("Hello, world!")</pre>
# 			<div class="tab-buttons">
# 				{}
# 			</div>
# 			{{}}
# 			<a href="index.html">Back to Index</a>
# 		</div>
# 		<script>
# 			var tabs = document.querySelectorAll('.tab');
# 			var buttons = document.querySelectorAll('.tab-button');
# 			buttons.forEach(function(button, index) {{
# 				button.addEventListener('click', function() {{
# 					tabs.forEach(function(tab) {{
# 						tab.classList.remove('active');
# 					}});
# 					buttons.forEach(function(button) {{
# 						button.classList.remove('active');
# 					}});
# 					tabs[index].classList.add('active');
# 					buttons[index].classList.add('active');
# 				}});
# 			}});
# 		</script>
# 	</body>
# </html>

# '''


# # Create a directory to store the HTML files
# if not os.path.exists('html_files'):
#     os.makedirs('html_files')


# # Generate an HTML file for each key
# for key in iphopdict:
#     outputfilename = os.path.join('html_files', '{}.html'.format(key))
#     host = ("Likely host: " + iphopdict[key])
#     DNA = "The DNA of the phage:"
#     contig = virusdict[key]
#     picture = "test.jpg"
#     html = html_template.format(outputfilename, outputfilename, key, host, picture, DNA, contig, key)
#     with open(outputfilename, 'w') as f:
#         f.write(html)

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

<h2>Tabs</h2>
<p>Click on the buttons inside the tabbed menu:</p>



"""



bottomofpage = """
<script>
function openCity(evt, cityName) {
  var i, tabcontent, tablinks;
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
  document.getElementById(cityName).style.display = "block";
  evt.currentTarget.className += " active";
}
</script>
   
</body>
</html> 
"""

opentab = """

  	<button class="tablinks" onclick="openCity(event, '{}')">{}</button>

"""

tabs = """
<div id="{}" class="tabcontent">
	<h1>{}</h1>
	<p><strong>Host:</strong> {}</p>
	<p><strong>Picture:</strong></p>
	<img class="picture" src="{}" alt="Illustration of annotated phage">
	<p><strong>DNA:</strong> {}</p>
	<p><strong>Contig:</strong> {}</p>
</div>
"""


# Create a directory to store the HTML files
if not os.path.exists('webresults'):
    os.makedirs('webresults')


# Generate an HTML file for each key

buttonstring = """<div class="tab">"""
tabstring = """"""
with open(outputfilename, 'w') as f:  
	f.write(webpage)
	for key in iphopdict:
		print(key)
		print(virusdict[key][:50])
		host = ("Likely host: " + iphopdict[key])
		DNAtext = "The DNA of the phage:"
		contig = virusdict[key]
		picture = "test.jpg"
		buttonstring += (opentab.format(key,key))
		tabstring += tabs.format(key,key,host,picture,DNAtext,contig)
	buttonstring += "</div>"
	f.write(buttonstring)
	f.write(tabstring)
	f.write(bottomofpage)
    
        
    