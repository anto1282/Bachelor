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
            
            print(phagekey)
        else:
            phagecontig += line
    
        linecount += 1
    #Adding the last key/value combination to the set
    virusdict[phagekey] = phagecontig

iphopdict = dict()
with open(iphoppredictions, 'r') as file:
    linecount = 0 
    for line in file:
        if linecount > 0:
            line = line.split(',')
            iphopdict[line[0]] = line[2]
        linecount += 1

print(virusdict.keys())

print(iphopdict)

html_template = '''
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>{}</title>
		<style>
			body {{
				font-family: Arial, sans-serif;
			}}
			.container {{
				margin: 0 auto;
				max-width: 800px;
			}}
			.tab {{
				display: none;
			}}
			.tab.active {{
				display: block;
			}}
			.tab-button {{
				background-color: #f2f2f2;
				border: none;
				color: black;
				padding: 10px;
				font-size: 16px;
				cursor: pointer;
			}}
			.tab-button.active {{
				background-color: #ccc;
			}}
			.picture {{
				max-width: 100%;
			}}
		</style>
	</head>
	<body>
		<div class="container">
			<h1>{}</h1>
			<p><strong>Key:</strong> {}</p>
			<p><strong>Host:</strong> {}</p>
			<p><strong>Picture:</strong></p>
			<img class="picture" src="{}" alt="Example Picture">
			<p><strong>DNA:</strong> {}</p>
			<p><strong>Contig:</strong> {}</p>
			<pre>print("Hello, world!")</pre>
			<div class="tab-buttons">
				{}
			</div>
			{}
			<a href="index.html">Back to Index</a>
		</div>
		<script>
			var tabs = document.querySelectorAll('.tab');
			var buttons = document.querySelectorAll('.tab-button');
			buttons.forEach(function(button, index) {{
				button.addEventListener('click', function() {{
					tabs.forEach(function(tab) {{
						tab.classList.remove('active');
					}});
					buttons.forEach(function(button) {{
						button.classList.remove('active');
					}});
					tabs[index].classList.add('active');
					buttons[index].classList.add('active');
				}});
			}});
		</script>
	</body>
</html>

'''


# Create a directory to store the HTML files
if not os.path.exists('pages'):
    os.makedirs('pages')

# Generate an HTML file for each key
for key in iphopdict:
    outputfilename = os.path.join('pages', '{}.html'.format(key))
    host = "Likely host: " + iphopdict[key]
    DNA = "The DNA of the phage:\n"
    contig = virusdict[key]
    picture = "test.jpg"
    html = html_template.format(outputfilename, key, host, picture, DNA, contig)
    with open(outputfilename, 'w') as f:
        f.write(html)

# #Creating a file for each phage with name, contig and genus
# with open(outputfilename,'w') as file:
#     for key in iphopdict:
        
        
#         file.write(html_template.format(outputfilename,key,host, DNA, contig))





