using UnityEngine;
using System.Collections;

public class GUIScript : MonoBehaviour {

	enum Behaviors {alignment, arrival, avoid, cohesion, departure, flee, flocking, leader, seek, separation, wander};
	
	
	float nativeVerticalResolution = 1200.0f; // place your native vertical resolution here
	public Camera topCam;
	public Camera perspCam;
	public GUISkin customSkin;
	public Texture2D alignment;
	public Texture2D arrival;
	public Texture2D avoid;
	public Texture2D cohesion;
	public Texture2D departure;
	public Texture2D flee;
	public Texture2D flocking;
	public Texture2D leader;
	public Texture2D seek;
	public Texture2D separation;
	public Texture2D wander;
	public Texture2D topview;
	public int behavior = (int)Behaviors.seek;
	
	GlobalScript gs;
	
void Start()
{
	gs = GameObject.Find("Global").GetComponent<GlobalScript>();
}
	
void OnGUI() 
{	
	
	GUI.skin = customSkin;
	
	// Makes GUI resolution independent
	GUI.matrix = Matrix4x4.TRS (new Vector3(0, 0, 0), Quaternion.identity, new Vector3 (Screen.height / nativeVerticalResolution, Screen.height / nativeVerticalResolution, 1)); 

	if( GUI.Button(new Rect (250, nativeVerticalResolution - alignment.height - 1000, alignment.width, alignment.height), alignment))
		gs.behavior = (int)Behaviors.alignment;

	if( GUI.Button(new Rect (400, nativeVerticalResolution - arrival.height - 1000, arrival.width, arrival.height), arrival))
		gs.behavior = (int)Behaviors.arrival;
	
		
	if( GUI.Button(new Rect (550, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), avoid))
	{
		if (gs.behavior != (int)Behaviors.avoid)
			gameObject.SendMessage("generateObstacles", 30);
		
		gs.behavior = (int)Behaviors.avoid;
	}
	
	if( GUI.Button(new Rect (700, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), cohesion))
		gs.behavior = (int)Behaviors.cohesion;

	if( GUI.Button(new Rect (850, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), departure))
		gs.behavior = (int)Behaviors.departure;
	
	if( GUI.Button(new Rect (1000, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), flee))	
		gs.behavior = (int)Behaviors.flee;
		
	if( GUI.Button(new Rect (1150, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), leader))
		gs.behavior = (int)Behaviors.leader;

	if ( GUI.Button(new Rect (1300, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), flocking))
		gs.behavior = (int)Behaviors.flocking;
		
	if( GUI.Button(new Rect (1450, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), seek))
		gs.behavior = (int)Behaviors.seek;
	
	if( GUI.Button(new Rect (1600, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), separation))
		gs.behavior = (int)Behaviors.separation;
	
	if( GUI.Button(new Rect (1750, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), wander))
		gs.behavior = (int)Behaviors.wander;
	
	if( GUI.Button(new Rect (1900, nativeVerticalResolution - cohesion.height - 1000, cohesion.width, cohesion.height), topview))
	{
		topCam.camera.enabled = true; 
	 	perspCam.camera.enabled = false;
	}
	
	if(gs.behavior != (int)Behaviors.avoid)
		gameObject.SendMessage("clearObstacles"); 
	 		
}
 	
}