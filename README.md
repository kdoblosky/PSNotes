Name: PSNotes

Version: 0.2

Author: Kevin Doblosky (kdoblosky@gmail.com)

Source: https://github.com/kdoblosky/PSNotes

Last Updated: 2014-02-19

Note-taking utility for PowerShell. 

I have a lot of projects that I'm juggling at any given time, and typically have at least one text file to contain notes for each. Opening up the correct file in Notepad++ takes too long, and using the built-in Add-Content and Get-Contents require retrieving the full path each time. I wanted a simpler solution.

This allows you to define any number of text files (referred to as notebooks in this project), and assign aliases to them. Once defined, date-stamped notes can easily be added, and the contents retrieved.

Includes several functions, aliases and variables.

Functions include:

- Get-Notebooks (alias nbs) - this will list all defined notebook aliases and paths
- Add-Notebook (alias anb) - this adds a new notebook and alias
- Get-Notes (alias gn) - retrieves the notes from a single notebook
- Add-NewNote (alias note) - Adds a date-stamped note to the specified notebook, optionally creating a new one
- Open-Notebook (alias onb) - Opens a notebook in a text editor. If the alias npp is defined, will use the editor that is an alias to, otherwise will use notepad.

Variables:
- $DefaultNotePath - specified where to create new notebooks, if a path is not provided.
- $NoteBookList - path to where list of notebooks is stored. The list is stored to disk as json.

Usage:

Dot-source PSNotes.ps1, or include its contents in your $profile.

```
# Create notebook list - assumes that $NoteBookList is set to a valid path.
# The file it points to doesn't need to exist yet, but the current user must
# have rights to create a file there:
$ > Get-Notebooks -Force

# Add a new notebook, with an alias of ABC:
$ > Add-Notebook -Alias ABC -NotebookPath D:\Scratch\ABC.txt

# Or, more compactly:
$ > anb ABC D:\Scratch\ABC.txt

# Add a note to ABC notebook:
$ > Add-NewNote -Notebook ABC -Note "Plan to take over the world is now 90% complete"

# Or, more compactly:
$ > note ABC "Plan to take over the world is now 90% complete"

# Create a new notebook in the default location, and add a note to it in one step:
$ > Add-NewNote -Notebook "DEF" -Note "My plan encountered an unexpected obstacle - ceiling fans." -Force

# Or, more compactly:
$ > note DEF "My plan encountered an unexpected obstacle - ceiling fans." -Force

# List all notebooks:
$> Get-Notebooks

Name                           Value                                                                                                 
----                           -----                                                                                                 
ABC                            D:\Scratch\ABC.txt                                                                                    
DEF                            D:\Notes\DEF.txt                                                                                      

# Get contents of notebook ABC:
$ > Get-Notes -Notebook ABC

# Or, more compactly:
$ > gn ABC
2014-02-18 - Plan to take over the world is now 90% complete

# Open notebook in editor
$ > onb ABC
```