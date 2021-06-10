# HelicalConnector
Copyright 2021 Cadence Design Systems, Inc. All rights reserved worldwide.

A Glyph script for generating constant pitch helical connectors around a primary axis.

![CreateHelicalConnectorGUI](https://raw.github.com/pointwise/HelicalConnector/master/ScriptImage.png)

## Creating Connectors
This script provides a way to create helical connectors by either typing points into the start or end field or manually selecting points from the current database. Once the points are selected, the connector is created with the number of periods and dimensions specified in the GUI around a primary axis. The direction of the connector may be flipped using the "Flip Orientation" button. This simply changes the direction of the connector to the opposite direction (i.e. going from left-to-right instead of from right-to-left).

### Notes
* The dimension variable must be an integer greater than 2
* The number of periods must be non-zero
* Manually input points must have a single space between each coordinate

### Example: Two period helical connector with different radii
* Dimension 150
* Periods 2.0
* Y-axis
* Start XYZ: 1 2 3
* End XYZ: 5 7 9

## Disclaimer
This file is licensed under the Cadence Public License Version 1.0 (the "License"), a copy of which is found in the LICENSE file, and is distributed "AS IS." 
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE. 
Please see the License for the full text of applicable terms.
