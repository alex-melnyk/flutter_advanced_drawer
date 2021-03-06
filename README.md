# flutter_advanced_drawer
An advanced drawer widget, that can be fully customized with size, text, color, radius of corners.

## Advanced Drawer States
| Drawer Open State | Drawer Closed State |
|:-:|:-:|
| ![Advanced Drawer Open State](./PREVIEW_OPENED.png) | ![Advanced Drawer Closed State](./PREVIEW_CLOSED.png) |

## AdvancedDrawer Parameters
|Parameter|Description|Type|Default|
|:--------|:----------|:---|:------|
|`child`|Screen widget|*Widget*|required|
|`drawer`|Drawer widget|*Widget*|required|
|`controller`|Widget controller|*AdvancedDrawerController*| |
|`backdropColor`|Backdrop color|*Color*| |
|`openRatio`|Opening ratio|*double*|0.75|
|`animationDuration`|Animation duration|*Duration*|300ms|
|`animationCurve`|Animation curve|*Curve*|Curves.easeInOut|
|`childDecoration`|Child container decoration|*BoxDecoration*|Shadow, BorderRadius|

## Preview
| Preview Tap | Preview Gesture |
|:-:|:-:|
| ![Advanced Drawer Tap Animation](./PREVIEW_TAP.gif) | ![Advanced Drawer Gestures](./PREVIEW_GESTURE.gif) |
