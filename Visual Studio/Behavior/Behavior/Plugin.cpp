#include "stdafx.h"
#include "Behavior.h"
#include "Alignment.h"
#include "Arrival.h"
#include "Avoid.h"
#include "Cohesion.h"
#include "Departure.h"
#include "Flee.h"
#include "Flocking.h"
#include "Leader.h"
#include "Seek.h"
#include "Separation.h"
#include "Wander.h"


#if _MSC_VER // this is defined when compiling with Visual Studio
#define EXPORT_API __declspec(dllexport) // Visual Studio needs annotating exported functions with this
#else
#define EXPORT_API // XCode does not need annotating exported functions, so define is empty
#endif

extern "C"
{
	//Behavioral Animation

	enum Behaviors { alignment, arrival, avoid, cohesion, departure, flee, 
					flocking, leader, seek, separation, wander};

	//struct used to get actor data from Unity
	typedef struct
	{
		float gPos[3];
		float lVel[3];
		float aVel[3];
		float gOrient[4];
		float gITens[4];
		float mass;
		int agentID;

	} actorParameter;

	//struct used to get obstacle data from Unity 
	typedef struct
	{
		float gPos[3];
		float radius;

	} obstacleParameter;

	//copies data from actorParameter to Actor struct
	void copy(actorParameter& ap, Actor& A)
	{
		A.globalPosition = vec3(ap.gPos[0], ap.gPos[1], ap.gPos[2]);
		A.linearVelocity = vec3(ap.lVel[0], ap.lVel[1], ap.lVel[2]);
		A.angularVelocity = vec3(ap.aVel[0], ap.aVel[1], ap.aVel[2]);

		Quaternion q1(ap.gOrient[3], ap.gOrient[0], ap.gOrient[1], ap.gOrient[2]);
		A.globalOrientation.FromQuaternion(q1);
		Quaternion q2(ap.gITens[3], ap.gITens[0], ap.gITens[1], ap.gITens[2]);
		A.globalInertialTensor.FromQuaternion(q2);

		A.mass = ap.mass;
		A.agentID = ap.agentID;
	}

	static int CurrentBehavior;
	static vector<Actor> AgentList;
	static vector<Obstacle> ObstacleList;
	static vec3* m_vWander;

	void EXPORT_API initialize(int agentcount, int behavior)
	{
		CurrentBehavior = behavior;
		m_vWander = new vec3[agentcount];
	}

	//store all actor data from Unity in AgentList 
	void EXPORT_API transferActorData(actorParameter agents[], int agentcount, int behavior)
	{
		CurrentBehavior = behavior;
		AgentList.clear();
		for (int i=0; i<agentcount; i++)
		{
			Actor A;
			copy(agents[i], A);
			AgentList.push_back(A);
		}
	}

	void CalculateDesiredVelocity(int agentID, vec3 target, vec3& dvel)
	{
		vec3 dv(0,0,0);
		Actor A = AgentList[agentID];
		int behavior = CurrentBehavior;

		if (behavior == alignment)
		{
			Alignment a(target, AgentList);
			dv = a.CalculateDesiredVelocity(A);
		}
		if (behavior == arrival)
		{
			Arrival a(target);
			dv = a.CalculateDesiredVelocity(A);
		}
		if (behavior == avoid)
		{
			Avoid a(target, ObstacleList);
			dv = a.CalculateDesiredVelocity(A);
		}
		if (behavior == cohesion)
		{
			Cohesion b(AgentList);
			dv = b.CalculateDesiredVelocity(A);
		}
		if (behavior == departure)
		{
			Departure d(target);
			dv = d.CalculateDesiredVelocity(A);
		}
		if (behavior == flee)
		{
			Flee f(target);
			dv = f.CalculateDesiredVelocity(A);
		}
		if (behavior == flocking)
		{
			Flocking f(target, AgentList);
			dv = f.CalculateDesiredVelocity(A);
		}
		if (behavior == leader)
		{
			Leader l(target, AgentList);
			dv = l.CalculateDesiredVelocity(A);
		}
		if (behavior == seek)
		{
			Seek s(target);
			dv = s.CalculateDesiredVelocity(A);
		}
		if (behavior == separation)
		{
			Separation s(target, AgentList);
			dv = s.CalculateDesiredVelocity(A);
		}
		if (behavior == wander)
		{
			vec3 mvw = m_vWander[agentID];
			Wander w(mvw);
			dv = w.CalculateDesiredVelocity(A);

			//save wander direction
			m_vWander[agentID] = w.m_vWander;
		}

		if (dv.Length() > Behavior::g_fMaxSpeed)
 		{
			dv.Normalize();
			dv *= Behavior::g_fMaxSpeed;
 		}

		dvel = dv;
	}

	//wrapper function for Behavior::CalculateForce
	void EXPORT_API CalculateForce(int agentID, float* target, float* force)
	{
		vec3 dv;
		CalculateDesiredVelocity(agentID, vec3(target[0], target[1], target[2]), dv);
		
		Seek s(vec3(0,0,0));
		vec3 f = s.CalculateForce(AgentList[agentID], dv);

		for (int i=0; i<3; i++)
			force[i] = f[i];
	}

	//wrapper function for Behavior::CalculateTorque
	void EXPORT_API CalculateTorque(int agentID, float* target, float* torque)
	{
		vec3 dv;
		CalculateDesiredVelocity(agentID, vec3(target[0], target[1], target[2]), dv);
		
		Seek s(vec3(0,0,0));
		vec3 t = s.CalculateTorque(AgentList[agentID], dv);

		for (int i=0; i<3; i++)
			torque[i] = t[i];
	}


	//stores obstacle data from Unity in ObstacleList
	void EXPORT_API transferObstacleData(obstacleParameter obstacles[], int obstaclecount)
	{
		for (int i=0; i<obstaclecount; i++)
		{
			Obstacle O;
			O.globalPosition = vec3(obstacles[i].gPos[0], obstacles[i].gPos[1], obstacles[i].gPos[2]);
			O.radius = obstacles[i].radius;
			ObstacleList.push_back(O);
		}
	}
	void EXPORT_API clearObstacleData()
	{
		ObstacleList.clear(); 
	}
}

