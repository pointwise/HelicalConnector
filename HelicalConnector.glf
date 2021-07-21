#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

#--This script allows the user to select two points on a cylindrical body in
#--Pointwise and creates a helical connector between those two points.
#--The script opens a user input box that allows the user to specify
#--the dimension of the connector as well as the axis about which to
#--create the connector.
#
#--The user will select an axis options and will also enter a numerical dimension
#--the dimension parameter must be an integer value greater than 2. The user
#--can then select to pick two end points for the helical connector they wish
#--to create, to end the program with their most recent selection, or to abort
#--and cancel all selections made during the execution of the script.
#
#--Inputs: axis, dimension, start point, end point, opposite side connector
#
#--Restrictions:
#--The cylinder must be located at the origin and uses X,Y, Z coordinates.
#--The user must input a dimension value greater than 2 and select an axis. 
#--Axis are only rectangular (i.e. x, y, z).

# Load Pointwise Glyph package
package require PWI_Glyph 2.4

pw::Script loadTk

# Set global variables to initial values
set pi [expr 4.0*atan(1.0)]
set origDispXYZAxes [pw::Display getShowXYZAxes]
pw::Display setShowXYZAxes 1

set axis "Y"
set conDim 100
set startPt {0 0 0}
set endPt {0 0 0}
set period 1.0
set otherSd 0

# Hierarchy for main GUI
set w(TitleBlock)          .title
set w(InputBlock)          .input
  set w(LabelDimension)    $w(InputBlock).ldim
  set w(EntryDimension)    $w(InputBlock).edim
  set w(LabelPeriod)       $w(InputBlock).lper
  set w(EntryPeriod)       $w(InputBlock).eper
  set w(LabelAxis)         $w(InputBlock).laxis
  set w(RadioButtons)      $w(InputBlock).rbuttons
    set w(RButtonXAxis)    $w(RadioButtons).rbxaxis
    set w(RButtonYAxis)    $w(RadioButtons).rbyaxis
    set w(RButtonZAxis)    $w(RadioButtons).rbzaxis
  set w(LabelStartPoint)   $w(InputBlock).lblstpt
  set w(LabelEndPoint)     $w(InputBlock).lblendpt
  set w(EntryStartPoint)   $w(InputBlock).entrystpt
  set w(EntryEndPoint)     $w(InputBlock).entryendpt
  set w(ButtonStartPoint)  $w(InputBlock).bstartpnt
  set w(ButtonEndPoint)    $w(InputBlock).bendpnt
set w(CreateFlipBlock)     .createflip
  set w(CreateConnector)   $w(CreateFlipBlock).createcon
  set w(OtherSide)         $w(CreateFlipBlock).otherside
set w(BottomBlock)         .bottom
  set w(Logo)              $w(BottomBlock).logo
  set w(OkButton)          $w(BottomBlock).bok
  set w(CancelButton)      $w(BottomBlock).bcancel
  set w(ApplyButton)       $w(BottomBlock).apply
set w(MessageBlock)        .msg

#-- PROC: setTitleFont
#-- set the font for the input widget to be bold and 1.5 times larger than
#-- the default font
proc setTitleFont { l } {
  global titleFont
  if { ! [info exists titleFont] } {
    set fontSize [font actual TkCaptionFont -size]
    set titleFont [font create -family [font actual TkCaptionFont -family] \
        -weight bold -size [expr {int(1.5 * $fontSize)}]]
  }
  $l configure -font $titleFont
}

#-- PROC: quit
#-- This procedure resets the axis to the original setting then closes the script

proc quit {} {
  global origDispXYZAxes 
  pw::Display setShowXYZAxes $origDispXYZAxes
  if [info exists mode] {
    $mode abort
    unset mode
  }
  destroy .
}

#-- PROC: otherSide
#-- This procedure checks the condition that the user wants the connector to go 
#-- on the side opposite the path that it was originally going.

proc otherSide {} {
  global otherSd
  # Switch the side once the checkbutton is toggled on or off.

  set otherSd [expr ($otherSd+1) % 2]
  helixCon
}

#-- PROC: rta2xyz
#-- Convert from polar to rectangular coordinates
#-- r-Radius t-Theta a-Axis

proc rta2xyz { axis point } {
  set r [lindex $point 0]
  set t [lindex $point 1]
  set a [lindex $point 2]
  switch $axis {
    "X" {
      set x $a
      set y [expr $r*cos($t)]
      set z [expr $r*sin($t)]
    }
    "Y" {
      set y $a
      set z [expr $r*cos($t)]
      set x [expr $r*sin($t)]
    }
    "Z" {
      set z $a
      set x [expr $r*cos($t)]
      set y [expr $r*sin($t)]
    }
  }
  return [list $x $y $z]
}

#-- PROC: xyz2rta
#-- Convert from rectangular to polar coordinates
#-- r-Radius t-Theta a-Axis

proc xyz2rta { axis point } {
  global pi

  set x [expr double( [lindex $point 0] ) ]
  set y [expr double( [lindex $point 1] ) ]
  set z [expr double( [lindex $point 2] ) ]
  switch $axis {
  "X" {
      set r [expr sqrt( $y*$y + $z*$z )]
      set theta [expr atan2($z,$y)]
      set a $x
    }
  
  "Y" {
      set r [expr sqrt( $z*$z + $x*$x )]
      set theta [expr atan2($x,$z)]
      set a $y
    }
  "Z" {
      set r [expr sqrt( $x*$x + $y*$y )]
      set theta [expr atan2($y,$x)]
      set a $z
    }
  } 
  if { $theta < 0 } {
    set theta [expr 2*$pi+$theta]
  }
  return [list $r $theta $a]
}

#-- PROC: helixCon
#-- This procedure builds the connector using the user specified start and end 
#-- points.

proc helixCon { } {
  global mode pi conDim otherSd period
  global axis endPtT endPtA radius2 startPt startPtT startPtA radius1 axis

  if [info exists mode] {
    $mode abort
  }
  set mode [pw::Application begin Create -monitor]
 
  set thetaDist [expr $startPtT - $endPtT - $period*2*$pi]

  # Create the helix on the other side.
  if { $otherSd } {
    set thetaDist [expr $period*2*$pi - ($endPtT - $startPtT)]
  }

  set axialDist [expr $endPtA-$startPtA]
  set radialDist [expr $radius1 - $radius2]
  set deltaT [expr $thetaDist/($conDim-1)]
  set deltaA [expr abs( $axialDist )/($conDim-1)]
  set deltaR [expr abs( $radialDist )/($conDim-1)]
  
  set con [pw::Connector create]
  set segSpline [pw::SegmentSpline create]
  $segSpline addPoint $startPt
  for { set i 1 } { $i < $conDim } { incr i } {
    if { $radialDist > 0.0 } {
      set radiusNew [expr $radius1 - $i*$deltaR]
    } else {
      set radiusNew [expr $radius1 + $i*$deltaR]
    }
    if { $axialDist > 0.0 } {
      set a [expr $startPtA + $i*$deltaA]
    } else {
      set a [expr $startPtA - ($i*$deltaA)]
    }
    set t [expr $startPtT - $i*$deltaT]
    set pt "$radiusNew $t $a"
    $segSpline addPoint [rta2xyz $axis $pt]
  }
  $con addSegment $segSpline
  $con setDimension $conDim

  # Display new connector for the user to validate orientation and coordinates
  pw::Display update
}

#-- PROC: buttonSelect
#-- This procedure allows the user to pick a point from the pointwise display
#-- and assign it to a variable in the outer scope

proc buttonSelect { ptVarName } {
  upvar $ptVarName pt
  set temp $pt

  wm withdraw .
  if [catch { pw::Display selectPoint } pickedPt] {
    set pt $temp
  } elseif [catch { eval [join [list pwu::Vector3 set $pickedPt]] } pt] {
    set pt $temp
  }
  wm deiconify .
}

#-- PROC: applyConnector
#-- This procedure resets all values and creates a new connector. This
#-- procedure also ends the current mode finalizing the current connector.

proc applyConnector { } {
  global w otherSd mode

  # Reset all starting values to initial values to clean the inputs in GUI
  if [info exists mode] {
    $mode end
    unset mode
  }

  set otherSd 0

  # Reset all available options from the GUI selection
  $w(OtherSide) configure -state disabled
  $w(ApplyButton) configure -state disabled
  $w(OkButton) configure -state disabled
  $w(CreateConnector) configure -state normal

  # It is assumed that if the user selects apply, at least two points will have
  # been created meaning that they can now use the point selection buttons.

  $w(ButtonStartPoint) configure -state normal
  $w(ButtonEndPoint) configure -state normal
}

#-- PROC: isValidPt
#-- Check that the input argument is a valid list of 3 doubles

proc isValidPt { pt } {
  if [catch { eval [join [list pwu::Vector3 set $pt]] }] {
    return 0
  }
  return 1
}

#-- PROC: createConnector
#-- This procedure sets the start and end points for the new connector and then
#-- checks the end point to verify the start and end point are not the same value.
#-- The procedure helixcon is then called that will actually create the connector.

proc createConnector { } {
  global w startPt endPt period axis conDim
  global startPtT startPtA radius1 endPtT endPtA radius2

  if { ![string is double $period] } {
    tk_messageBox -message "Number of periods must be a double." -type ok \
                  -icon error -title "Invalid Input Error"
    return
  }

  if { ![string is integer $conDim] || ($conDim <= 2) } {
    tk_messageBox -message "Connector dimension must greater than 2." -type ok \
                  -icon error -title "Invalid Input Error"
    return
  }

  if { ! [isValidPt $startPt] } {
    tk_messageBox -message "Start point is not valid." -type ok \
                  -icon error -title "Invalid Input Error"
    return
  }
  
  if { ! [isValidPt $endPt] } {
    tk_messageBox -message "End point is not valid." -type ok \
                  -icon error -title "Invalid Input Error"
    return
  }

  if [pwu::Vector3 equal -tolerance [pw::Grid getNodeTolerance] $startPt $endPt] {
    tk_messageBox -message "End point must not be the same as the start point." -type ok \
                  -icon error -title "Invalid End Point" 
    return
  }

  foreach { radius1 startPtT startPtA } [xyz2rta $axis $startPt] { continue }
  foreach { radius2 endPtT endPtA } [xyz2rta $axis $endPt] { continue }

  # Create the connector
  helixCon
  $w(OtherSide) configure -state normal
  $w(ApplyButton) configure -state normal
  $w(OkButton) configure -state normal
}

#--PROC: makeWindow
#--This procedure creates the GUI for the script and accepts the user inputs

proc makeWindow { } {
  global w startPt endPt conDim axis period

  set note "Note: Assume cylinder is a principle axis (X/Y/Z)"
  
  wm title . "Create Helical Connector"
  # create the widgets
  label $w(TitleBlock) -text "Create Helical Connector"
  setTitleFont $w(TitleBlock)
 
  frame $w(InputBlock)
 
  label $w(LabelDimension) -text "Dimension:" -anchor e
  entry $w(EntryDimension) -width 6 -bd 2 -textvariable conDim
  label $w(LabelPeriod) -text "# Periods:" -anchor e
  entry $w(EntryPeriod) -width 6 -bd 2 -textvariable period
 
  label $w(LabelAxis) -text "Axis:" -padx 2 -anchor e
 
  frame $w(RadioButtons)
 
  radiobutton $w(RButtonXAxis) -text "X-Axis" -variable axis -value X
  radiobutton $w(RButtonYAxis) -text "Y-Axis" -variable axis -value Y
  radiobutton $w(RButtonZAxis) -text "Z-Axis" -variable axis -value Z
 
  pack $w(RButtonXAxis) $w(RButtonYAxis) $w(RButtonZAxis) -in \
                                           $w(RadioButtons) -side left
 
  label $w(LabelStartPoint) -text "Start XYZ:" -anchor e
  entry $w(EntryStartPoint) -width 6 -bd 2 -textvariable startPt
  button $w(ButtonStartPoint) -text "Pick Point" -command { buttonSelect startPt } \
                              -state disabled
  label $w(LabelEndPoint) -text "End XYZ:" -anchor e
  entry $w(EntryEndPoint) -width 6 -bd 2 -textvariable endPt
  button $w(ButtonEndPoint) -text "Pick Point" -command { buttonSelect endPt } \
                           -state disabled
  message $w(MessageBlock) -text $note -background beige \
                      -bd 2 -relief sunken -padx 5 -pady 5 -anchor w \
                      -justify left -width 300
  frame $w(CreateFlipBlock)
  button $w(OtherSide) -text "Flip Orientation" -command { otherSide } \
                        -state disabled
  button $w(CreateConnector) -text "Create Connector" -command { createConnector }
  
  frame $w(BottomBlock) -relief sunken

  button $w(CancelButton) -text "Cancel" -command { quit }
  button $w(OkButton) -text "Ok" -state disabled -command { applyConnector; quit }
  button $w(ApplyButton) -text "Apply" -state disabled -command { applyConnector }
  label $w(Logo) -image [cadenceLogo] -bd 0 -relief flat

  # Determine if the current grid has any points for the user to select from
  set numPoints [pw::Grid getPointCount]
  if { $numPoints >=1 } { 
    $w(ButtonStartPoint) configure -state normal
    $w(ButtonEndPoint) configure -state normal
  }

  # lay out the form
  pack $w(TitleBlock) -side top
  pack [frame .sp -bd 1 -height 2 -relief sunken] -pady 4 -side top -fill x
  pack $w(InputBlock) -side top -fill both -expand 1

  # lay out the form in a grid
  grid $w(LabelDimension) $w(EntryDimension) -sticky ew -pady 3 -padx 3
  grid $w(LabelPeriod) $w(EntryPeriod) -sticky ew -pady 3 -padx 3
  grid $w(LabelAxis) $w(RadioButtons) -sticky ew -pady 3 -padx 3
  grid $w(LabelStartPoint) $w(EntryStartPoint) $w(ButtonStartPoint) \
                            -sticky ew -pady 3 -padx 3
  grid $w(LabelEndPoint) $w(EntryEndPoint) $w(ButtonEndPoint) \
                           -sticky ew -pady 3 -padx 3

  # give all extra space to the second (last) column
  grid columnconfigure $w(InputBlock) 1 -weight 1

  pack $w(CreateFlipBlock) -fill x -padx 2 -pady 4

  grid columnconfigure $w(CreateFlipBlock) {0 1} -uniform allTheSame
  grid $w(CreateConnector) $w(OtherSide) -sticky ew -pady 3 -padx 30

  pack $w(MessageBlock) -side bottom -fill x -anchor s
  pack $w(BottomBlock) -fill x -side bottom -padx 2 -pady 4 -anchor s
  pack $w(CancelButton) -side right -padx 2
  pack $w(ApplyButton) -side right -padx 2
  pack $w(OkButton) -side right -padx 2
  pack $w(Logo) -side left -padx 5

  # Make the window unscalable
  update
  wm minsize . [winfo width .] [winfo height .]
  wm maxsize . [winfo width .] [winfo height .]
}

#-- PROC: cadenceLogo
#-- load a GIF image from a file in base-64 encoded form (Cadence Design Systems Logo)
proc cadenceLogo { } {
  set logoData "
R0lGODlhgAAYAPQfAI6MjDEtLlFOT8jHx7e2tv39/RYSE/Pz8+Tj46qoqHl3d+vq62ZjY/n4+NT
T0+gXJ/BhbN3d3fzk5vrJzR4aG3Fubz88PVxZWp2cnIOBgiIeH769vtjX2MLBwSMfIP///yH5BA
EAAB8AIf8LeG1wIGRhdGF4bXD/P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIe
nJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtdGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1w
dGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYxIDY0LjE0MDk0OSwgMjAxMC8xMi8wNy0xMDo1Nzo
wMSAgICAgICAgIj48cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudy5vcmcvMTk5OS8wMi
8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmY6YWJvdXQ9IiIg/3htbG5zO
nhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0
cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUcGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh
0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0idX
VpZDoxMEJEMkEwOThFODExMUREQTBBQzhBN0JCMEIxNUM4NyB4bXBNTTpEb2N1bWVudElEPSJ4b
XAuZGlkOkIxQjg3MzdFOEI4MTFFQjhEMv81ODVDQTZCRURDQzZBIiB4bXBNTTpJbnN0YW5jZUlE
PSJ4bXAuaWQ6QjFCODczNkZFOEI4MTFFQjhEMjU4NUNBNkJFRENDNkEiIHhtcDpDcmVhdG9yVG9
vbD0iQWRvYmUgSWxsdXN0cmF0b3IgQ0MgMjMuMSAoTWFjaW50b3NoKSI+IDx4bXBNTTpEZXJpZW
RGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MGE1NjBhMzgtOTJiMi00MjdmLWE4ZmQtM
jQ0NjMzNmNjMWI0IiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjBhNTYwYTM4LTkyYjItNDL/
N2YtYThkLTI0NDYzMzZjYzFiNCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g
6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovp6Ofm5e
Tj4uHg397d3Nva2djX1tXU09LR0M/OzczLysnIx8bFxMPCwcC/vr28u7q5uLe2tbSzsrGwr66tr
KuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0
c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1cW1pZWFdWVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj0
8Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQ
QDAgEAACwAAAAAgAAYAAAF/uAnjmQpTk+qqpLpvnAsz3RdFgOQHPa5/q1a4UAs9I7IZCmCISQwx
wlkSqUGaRsDxbBQer+zhKPSIYCVWQ33zG4PMINc+5j1rOf4ZCHRwSDyNXV3gIQ0BYcmBQ0NRjBD
CwuMhgcIPB0Gdl0xigcNMoegoT2KkpsNB40yDQkWGhoUES57Fga1FAyajhm1Bk2Ygy4RF1seCjw
vAwYBy8wBxjOzHq8OMA4CWwEAqS4LAVoUWwMul7wUah7HsheYrxQBHpkwWeAGagGeLg717eDE6S
4HaPUzYMYFBi211FzYRuJAAAp2AggwIM5ElgwJElyzowAGAUwQL7iCB4wEgnoU/hRgIJnhxUlpA
SxY8ADRQMsXDSxAdHetYIlkNDMAqJngxS47GESZ6DSiwDUNHvDd0KkhQJcIEOMlGkbhJlAK/0a8
NLDhUDdX914A+AWAkaJEOg0U/ZCgXgCGHxbAS4lXxketJcbO/aCgZi4SC34dK9CKoouxFT8cBNz
Q3K2+I/RVxXfAnIE/JTDUBC1k1S/SJATl+ltSxEcKAlJV2ALFBOTMp8f9ihVjLYUKTa8Z6GBCAF
rMN8Y8zPrZYL2oIy5RHrHr1qlOsw0AePwrsj47HFysrYpcBFcF1w8Mk2ti7wUaDRgg1EISNXVwF
lKpdsEAIj9zNAFnW3e4gecCV7Ft/qKTNP0A2Et7AUIj3ysARLDBaC7MRkF+I+x3wzA08SLiTYER
KMJ3BoR3wzUUvLdJAFBtIWIttZEQIwMzfEXNB2PZJ0J1HIrgIQkFILjBkUgSwFuJdnj3i4pEIlg
eY+Bc0AGSRxLg4zsblkcYODiK0KNzUEk1JAkaCkjDbSc+maE5d20i3HY0zDbdh1vQyWNuJkjXnJ
C/HDbCQeTVwOYHKEJJwmR/wlBYi16KMMBOHTnClZpjmpAYUh0GGoyJMxya6KcBlieIj7IsqB0ji
5iwyyu8ZboigKCd2RRVAUTQyBAugToqXDVhwKpUIxzgyoaacILMc5jQEtkIHLCjwQUMkxhnx5I/
seMBta3cKSk7BghQAQMeqMmkY20amA+zHtDiEwl10dRiBcPoacJr0qjx7Ai+yTjQvk31aws92JZ
Q1070mGsSQsS1uYWiJeDrCkGy+CZvnjFEUME7VaFaQAcXCCDyyBYA3NQGIY8ssgU7vqAxjB4EwA
DEIyxggQAsjxDBzRagKtbGaBXclAMMvNNuBaiGAAA7"

  return [image create photo -format GIF -data $logoData]
}

makeWindow

::tk::PlaceWindow . widget

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
