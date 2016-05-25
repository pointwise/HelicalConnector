# Create Helical Connector
A Glyph script for generating constant pitch helical connectors around a primary axis.

![CreateHelicalConnectorGUI](https://raw.github.com/pointwise/HelicalConnector/master/ScriptImage.png)

## Creating Connectors
This script provides a way to create helical connectors by either typing points into the start or end field or manually selecting points from the current database. Once the points are selected, the connector is created with the number of periods and dimensions specified in the GUI around a primary axis. The direction of the connector may be flipped using the "Flip Orientation" button. This simply changes the direction of the connector to the opposite direction (i.e. going from left-to-right instead of from right-to-left).

### Notes
* The dimension variable must be an integer greater than 2
* The number of periods must be non-zero
* Manually input points must have a single space between each coordinate

### Example, 2 period helical connector with different radii
* Dimension 150
* Periods 2.0
* Y-axis
* Start XYZ: 1 2 3
* End XYZ: 5 7 9

## Disclaimer
Scripts are freely provided. They are not supported products of Pointwise, Inc. Some scripts have been written and contributed by third parties outside of Pointwise's control.

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, WITH REGARD TO THESE SCRIPTS. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR INABILITY TO USE THESE SCRIPTS EVEN IF POINTWISE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE FAULT OR NEGLIGENCE OF POINTWISE.
