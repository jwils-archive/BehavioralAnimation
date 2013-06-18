using UnityEngine;
using System.Collections;
using System;
using System.Runtime.InteropServices;

public class BehaviorScript : MonoBehaviour 
{
	enum Behaviors {alignment, arrival, avoid, cohesion, departure, flee, flocking, leader, seek, separation, wander};
	
	[DllImport("Behavior")]
	public static extern void CalculateForce(int agentID, float[] target, float[] force);
	
	[DllImport("Behavior")]
	public static extern void CalculateTorque(int agentID, float[] target, float[] torque);
	
	public GameObject target; 
	public Transform LeaderIndicator;
	public int agentID;
	
	bool idleSet = false;
	string idleAnimation;
	
	GlobalScript gscript;
	
	float[] result;			//stores values returned by dll functions
	float[] targetPos;		//target position parameter to dll functions

	void Start () 
	{
		gscript = GameObject.Find("Global").GetComponent<GlobalScript>(); 
		idleAnimation = "look";
		
		result = new float[3];
		targetPos = new float[3];
	}
	
	//update agent's position and orientation through forces and torques
	void FixedUpdate () 
	{	
		Vector3 t = target.transform.position;
		for (int i=0; i<3; i++)
			targetPos[i] = t[i];
		
		if (gscript.behavior == (int)Behaviors.leader) 
		{
			Vector3 leaderPos = gscript.agents[0].transform.position;
			LeaderIndicator.position = new Vector3 (leaderPos.x, leaderPos.y + 4.0f, leaderPos.z);
		}
		else
			LeaderIndicator.position = new Vector3(-2,-2,-2); 
		
		//transfers all data necessary for force and torque calculations from Unity to DLL
		gscript.transferData();
		
		CalculateForce(agentID, targetPos, result);
		rigidbody.AddForce(result[0], result[1], result[2]);
		
		CalculateTorque(agentID, targetPos, result);
		rigidbody.AddTorque(result[0], result[1], result[2]); 
	}
	
	//switch character animations according to speed
	void Update()
	{
		float vel = rigidbody.velocity.magnitude;
		
		if (vel < 0.1)
		{
			if (!idleSet)
			{
				idleSet = true;
				int r = UnityEngine.Random.Range(1,6);
				if (r==1)
					idleAnimation = "look";
				if (r==2)
					idleAnimation = "kick";
				if (r==3)
					idleAnimation = "handstand";
				if (r==4)
					idleAnimation = "dance";
				if (r==5)
					idleAnimation = "jump";
			}
			animation.CrossFade(idleAnimation);
		}
		if (vel > 0.1 && vel < 2)
		{
			animation.CrossFade("walk");
			idleSet = false;
		}
		if (vel >= 2)
		{
			animation["run"].speed = 0.8f;
			animation.CrossFade("run");
			idleSet = false;
		}
	}
}