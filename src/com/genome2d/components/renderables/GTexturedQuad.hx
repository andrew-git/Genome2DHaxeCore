package com.genome2d.components.renderables;
import flash.geom.Matrix;
import com.genome2d.geom.GMatrix;
import com.genome2d.context.filters.GFilter;
import com.genome2d.context.GContextCamera;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.node.GNode;
import com.genome2d.components.GComponent;
import com.genome2d.context.GContext;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.textures.GTexture;
import com.genome2d.geom.GFloatRectangle;

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
class GTexturedQuad extends GComponent implements IRenderable
{
    public var blendMode:Int = 1;

	public var texture:GTexture;
    //public var mousePixelEnabled:Bool = false;

    public var filter:GFilter;

	public function new(p_node:GNode) {
		super(p_node);
	}

	public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
		if (texture != null) {
			//trace(node.transform.g2d_worldScaleX + "," + node.transform.g2d_worldScaleY);
            if (p_useMatrix) {
                var matrix:GMatrix = node.core.g2d_renderMatrix;
                node.core.getContext().drawMatrix(texture, matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty, node.transform.g2d_worldRed, node.transform.g2d_worldGreen, node.transform.g2d_worldBlue, node.transform.g2d_worldAlpha, blendMode, filter);
            } else {
                node.core.getContext().draw(texture, node.transform.g2d_worldX, node.transform.g2d_worldY, node.transform.g2d_worldScaleX, node.transform.g2d_worldScaleY, node.transform.g2d_worldRotation, node.transform.g2d_worldRed, node.transform.g2d_worldGreen, node.transform.g2d_worldBlue, node.transform.g2d_worldAlpha, blendMode, filter);
            }
		}
	}	
	
	override public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
		if (p_captured && p_contextSignal.type == GMouseSignalType.MOUSE_UP) node.g2d_mouseDownNode = null;

		if (p_captured || texture == null || texture.width == 0 || texture.height == 0 || node.transform.g2d_worldScaleX == 0 || node.transform.g2d_worldScaleY == 0) {
			if (node.g2d_mouseOverNode == node) node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, 0, 0, p_contextSignal);
			return false;
		}

        // Invert translations
        var tx:Float = p_cameraX - node.transform.g2d_worldX;
        var ty:Float = p_cameraY - node.transform.g2d_worldY;

        if (node.transform.g2d_worldRotation != 0) {
            var cos:Float = Math.cos(-node.transform.g2d_worldRotation);
            var sin:Float = Math.sin(-node.transform.g2d_worldRotation);

            var ox:Float = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= node.transform.g2d_worldScaleX*texture.width;
        ty /= node.transform.g2d_worldScaleY*texture.height;

        tx += .5;
        ty += .5;

		if (tx >= -texture.pivotX / texture.width && tx <= 1 - texture.pivotX / texture.width && ty >= -texture.pivotY / texture.height && ty <= 1 - texture.pivotY / texture.height) {
            /*
			if (mousePixelEnabled && texture.getAlphaAtUV(tx+texture.pivotX/texture.width, ty+texture.pivotY/texture.height) == 0) {
				if (node.g2d_mouseOverNode == node) {
					node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, tx*texture.width+texture.pivotX, ty*texture.height+texture.pivotY, p_contextSignal);
				}
				return false;
			}
			/**/
            trace("here");
			node.dispatchNodeMouseSignal(p_contextSignal.type, node, tx*texture.width+texture.pivotX, ty*texture.height+texture.pivotY, p_contextSignal);
			if (node.g2d_mouseOverNode != node) {
				node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OVER, node, tx*texture.width+texture.pivotX, ty*texture.height+texture.pivotY, p_contextSignal);
			}
			
			return true;
		} else {
			if (node.g2d_mouseOverNode == node) {
				node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, tx*texture.width+texture.pivotX, ty*texture.height+texture.pivotY, p_contextSignal);
			}
		}
		
		return false;
	}

    public function getBounds(p_bounds:GFloatRectangle = null):GFloatRectangle {
        if (texture == null) {
            if (p_bounds != null) p_bounds.setTo(0, 0, 0, 0);
            else p_bounds = new GFloatRectangle(0, 0, 0, 0);
        } else {
            if (p_bounds != null) p_bounds.setTo(-texture.width*.5-texture.pivotX, -texture.height*.5-texture.pivotY, texture.width, texture.height);
            else p_bounds = new GFloatRectangle(-texture.width*.5-texture.pivotX, -texture.height*.5-texture.pivotY, texture.width, texture.height);
        }

        return p_bounds;
    }
}