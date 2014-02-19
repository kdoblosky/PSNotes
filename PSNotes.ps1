

# Where to store notebooks if no path is provided
$DefaultNotePath = "D:\Notes"

# Where to store list of notebooks
$NoteBookList = Join-Path $DefaultNotePath NotesList.json

Function Get-Notebooks([switch]$Force) {
<#
.SYNOPSIS
Gets hashmap of notebooks currently configured.

.DESCRIPTION
Gets hashmap of notebooks currently configured. It attempts to load them from the json file
configured in $NoteBookList. If this file doesn't exist, and the Force parameter is present,
it will attempt to create this file.

.PARAMETER Force
If the file containing the list of notebooks (defined in $NoteBookList) doesn't exist, -Force
will attempt to create it.

.EXAMPLE
$ > Get-Notebooks

Name                           Value
----                           -----
KMD                            D:\Notes\KMD.txt
QRS                            D:\Projects\PS\QRSNotes.txt
XYZ                            D:\Notes\XYZ.txt

.EXAMPLE
$ > Get-Notebooks -Force
Notebook list doesn't exist. Creating it at D:\Notes\Notebooklist.json

.NOTES
Written by Kevin Doblosky (kdoblosky@gmail.com). Licensed under an MIT license.
#>
    # Make sure there is a variable defined for NoteBookList
    try {
        Get-Variable NoteBookList -ErrorAction Stop | Out-Null
    } catch {
        throw "`$NoteBookList is undefined. It should contain a path to a file containing json formatted list of notebooks."
    }

    $notebooks = [ordered]@{}
    if (! (Test-Path $NoteBookList) ) {
        if ($Force) {
            try {
                Write-Host "Notebook list doesn't exist. Creating it at $NoteBookList..."
                New-Item $NoteBookList -ItemType File -Force -ErrorAction Stop | Out-Null
            } catch {
                throw "Error creating NoteBookList at $NoteBookList"
            }
        } else {
            throw "Notebook list not found at $NoteBookList"
        }
    } else {
        try {
            (Get-Content $NoteBookList -Raw | ConvertFrom-Json).PSObject.Properties | Sort-Object Name | ForEach-Object { 
                $notebooks[$_.Name] = $_.Value 
            }
        } catch {
            # Need to validate this, for now ignoring any errors, so that it will return an empty hash
        }
    }

    $notebooks
}

Function Get-NotebookPath ($Alias) {
<#
.SYNOPSIS
Retrieves the path to the specified notebook.

.DESCRIPTION
Retrieves the path to the specified notebook.

.PARAMETER Alias
The alias for the notebook to retrieve.

.EXAMPLE
$ > Get-NotebookPath KMD
D:\Notes\KMD.txt

.NOTES
Written by Kevin Doblosky (kdoblosky@gmail.com). Licensed under an MIT license.
#>
    # TODO: Handle any errors from Get-Notebooks
    $notebooks = Get-Notebooks
    $notebooks[$Alias]
}

Function Add-Notebook($Alias, $NotebookPath) {
<#
.SYNOPSIS
Adds a notebook to the list.

.DESCRIPTION
Adds a new notebook to the list of notebooks.

.PARAMETER Alias
Alias of the notebook to add

.PARAMETER NotebookPath
Filesystem path to the notebook to be added.

.EXAMPLE
$ > Add-Notebook ZYX D:\Notes\ZYX-Notes.txt

.NOTES
Written by Kevin Doblosky (kdoblosky@gmail.com). Licensed under an MIT license.
#>
    # Get Existing Notebooks
    $notebooks = Get-Notebooks

    # Create $notebooks if it doesn't already exist
    if ($notebooks -eq $null) { $notebooks = @{} }

    $notebooks[$Alias] = $NotebookPath

    $notebooks | ConvertTo-Json | Set-Content $NoteBookList
}

Function Get-Notes($Notebook) {
<#
.SYNOPSIS
Retrieves all notes for the specified notebook.

.DESCRIPTION
Retrieves all notes for the specified notebook.

.PARAMETER Notebook
The notebook alias to retreive the notes from

.EXAMPLE
$ > Get-Notes KMD
2014-02-18 - Almost time to immanentize the eschaton
2014-02-18 - I can see the fnords!

.NOTES
Written by Kevin Doblosky (kdoblosky@gmail.com). Licensed under an MIT license.
#>
    $notebooks = Get-Notebooks
    
    if ($notebooks.Contains($Notebook)) {
        Get-Content $notebooks[$Notebook]
    } else {
        "Notebook does not exist"
    }
}

Function Add-NewNote {
<#
.SYNOPSIS
Adds a new note to a notebook.

.DESCRIPTION
Adds a new note, prepended by a datestamp, to a notebook. If notebook doesn't exist, and 
the -Force parameter is provided, will create the notebook at the default path.

.PARAMETER Notebook
Notebook alias to add the note to.

.PARAMETER Note
Note to add.

.PARAMETER Force
If provided, and the notebook doesn't exist, creates it.

.EXAMPLE
$ > Add-NewNote KMD "'Everything is theoretically impossible, until it is done.' - Robert A. Heinlein"

.EXAMPLE
$ > Add-NewNote QQQ "'Time is a drug. Too much of it kills you.' - Terry Prachtett" -Force
Notebook doesn't exist. Creating it at D:\Notes\QQQ.txt

.NOTES
Written by Kevin Doblosky (kdoblosky@gmail.com). Licensed under an MIT license.
#>
    param(
        $Notebook,
        $Note,
        [switch]$Force
    )

    $NotebookPath = Get-NotebookPath $Notebook

    if ($NotebookPath -eq $null) {
        if ($Force) {
            $NotebookPath = Join-Path $DefaultNotePath "$Notebook.txt"
            Write-Host "Notebook doesn't exist. Creating it at $NotebookPath."
            
            New-Item $NotebookPath -ItemType File -Force | Out-Null
            Add-Notebook $Notebook $NotebookPath
        }
        else {
            throw "Notebook doesn't exist"
        }
    }

    $datestamp = (Get-Date).ToString("yyyy-MM-dd")
    Add-Content -Path $NotebookPath -Value "$datestamp - $Note"
}

New-Alias -Name note -Value Add-NewNote
New-Alias -Name anb -Value Add-Notebook
New-Alias -Name gn -Value Get-Notes
New-Alias -Name nbs -Value Get-Notebooks