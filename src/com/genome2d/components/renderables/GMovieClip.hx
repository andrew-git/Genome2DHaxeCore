/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables;

import com.genome2d.context.GContextCamera;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTextureAtlas;

class GMovieClip extends GTexturedQuad
{
	private var g2d_speed:Float = 1000/30;
	private var g2d_accumulatedTime:Float = 0;
	
	private var g2d_currentFrame:Int = -1;

    private var g2d_lastUpdatedFrameId:Int = 0;

    #if swc @:extern #end
	public var currentFrame(get, never):Int;
    #if swc @:getter(currentFrame) #end
	inline private function get_currentFrame():Int {
		return g2d_currentFrame;
	}
	
	private var g2d_startIndex:Int = -1;
	private var g2d_endIndex:Int = -1;
	private var g2d_playing:Bool = true;
	
	private var g2d_textureAtlas:GTextureAtlas;
    #if swc @:extern #end
	public var textureAtlasId(get, set):String;
    #if swc @:getter(textureAtlasId) #end
	inline private function get_textureAtlasId():String {
		return (g2d_textureAtlas != null) ? g2d_textureAtlas.getId() : "";
	}
    #if swc @:setter(textureAtlasId) #end
	inline private function set_textureAtlasId(p_value:String):String {
		g2d_textureAtlas = (p_value != "") ? GTextureAtlas.getTextureAtlasById(p_value) : null;
		if (g2d_frameIds != null) texture = g2d_textureAtlas.getSubTexture(g2d_frameIds[0]);
		return g2d_textureAtlas.getId();
	}
	
	private var g2d_frameIds:Array<String>;
	private var g2d_frameIdsLength:Int = 0;
    #if swc @:extern #end
	public var frames(get, set):Array<String>;
    #if swc @:getter(frames) #end
	inline private function get_frames():Array<String> {
		return g2d_frameIds;
	}
    #if swc @:setter(frames) #end
	inline private function set_frames(p_value:Array<String>):Array<String> {
		g2d_frameIds = p_value;
		g2d_frameIdsLength = g2d_frameIds.length;
		g2d_currentFrame = 0;
		if (g2d_textureAtlas != null) texture = g2d_textureAtlas.getSubTexture(g2d_frameIds[0]);
		return g2d_frameIds;
	}
	
	public var repeatable:Bool = true;
	
	static private var g2d_count:Int = 0;
	
	/**
	 * 	@private
	 */
	public function new(p_node:GNode) {
		super(p_node);
	}
	
	/**
	 * 	Set texture atlas that should be used by this movie clip
	 */
	public function setTextureAtlas(p_textureAtlas:GTextureAtlas):Void {
		g2d_textureAtlas = p_textureAtlas;
		if (g2d_frameIds != null) texture = g2d_textureAtlas.getSubTexture(g2d_frameIds[0]);
	}

    #if swc @:extern #end
	public var frameRate(get, set):Int;
    #if swc @:getter(frameRate) #end
	inline private function get_frameRate():Int {
		return Std.int(1000 / g2d_speed);
	}
	/**
	 * 	Set framerate at which this clip should play
	 */
    #if swc @:setter(frameRate) #end
	inline private function set_frameRate(p_value :Int):Int {
		g2d_speed = 1000 / p_value;
		return p_value;
	}

    #if swc @:extern #end
	public var numFrames(get, never):Int;
    #if swc @:getter(numFrames) #end
	inline private function get_numFrames():Int {
		return g2d_frameIdsLength;
	}
	
	/**
	 * 	Go to a specified frame of this movie clip
	 */
	public function gotoFrame(p_frame:Int):Void {
		if (g2d_frameIds == null) return;
		g2d_currentFrame = p_frame;
		g2d_currentFrame %= g2d_frameIds.length;
		texture = g2d_textureAtlas.getSubTexture(g2d_frameIds[g2d_currentFrame]);
	}
	
	public function gotoAndPlay(p_frame:Int):Void {
		gotoFrame(p_frame);
		play();
	}
	
	public function gotoAndStop(p_frame:Int):Void {
		gotoFrame(p_frame);
		stop();
	}
	
	/**
	 * 	Stop playback of this movie clip
	 */
	public function stop():Void {
		g2d_playing = false;
	}
	
	/**
	 * 	Start the playback of this movie clip
	 */
	public function play():Void {
		g2d_playing = true;
	}
	
	/**
	 * 	@private
	 */
	override public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
		if (texture != null) {
            var currentFrameId:Int = node.core.getCurrentFrameId();
            if (g2d_playing && currentFrameId != g2d_lastUpdatedFrameId) {
                g2d_lastUpdatedFrameId = currentFrameId;
                g2d_accumulatedTime += g2d_node.core.getCurrentFrameDeltaTime();

                if (g2d_accumulatedTime >= g2d_speed) {
                    g2d_currentFrame += Std.int(g2d_accumulatedTime / g2d_speed);
                    if (g2d_currentFrame<g2d_frameIdsLength || repeatable) {
                        g2d_currentFrame %= g2d_frameIds.length;
                    } else {
                        g2d_currentFrame = g2d_frameIdsLength-1;
                    }

                    texture = g2d_textureAtlas.getSubTexture(g2d_frameIds[g2d_currentFrame]);
                }
                g2d_accumulatedTime %= g2d_speed;
            }

            super.render(p_camera, p_useMatrix);
        }
	}
}