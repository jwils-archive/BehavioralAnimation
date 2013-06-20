#include "StdAfx.h"
#include "Avoid.h"
#include "Arrival.h"

float Avoid::g_fKAvoid = 1000.0f;
float Avoid::g_fTAvoid = 5.0f;

Avoid::Avoid(vec3 target, const std::vector<Obstacle>& obstacles) : 
	Behavior("avoid"), m_pTarget(target), m_pObstacles(obstacles)
{
}

Avoid::Avoid(const Avoid& orig) : 
	Behavior(orig), m_pTarget(orig.m_pTarget), m_pObstacles(orig.m_pObstacles)
{
}

Behavior* Avoid::Clone() const
{
    return new Avoid(*this);
}

Avoid::~Avoid()
{
	 m_pTarget = vec3(0,0,0);
}

// Given the actor, return a desired velocity in world coordinates
// If an actor is near an obstacle, avoid adds either a tangential or
// normal response velocity
vec3 Avoid::CalculateDesiredVelocity(Actor& actor)
{

	
	Arrival arrive(m_pTarget);
	vec3 movement_vector = arrive.CalculateDesiredVelocity(actor);
	float lb = g_fTAvoid * actor.linearVelocity.Length();
	float rb = 1.0f; //WHERE is this?

    std::vector<Obstacle>::const_iterator it;
    for(it = m_pObstacles.begin(); it != m_pObstacles.end(); ++it)
	{
		Obstacle obstacle = *it;
		vec3 d_w = obstacle.globalPosition - actor.globalPosition;
		vec3 d_l = actor.globalOrientation * d_w;

		if (d_l[VX] <=  lb + rb + obstacle.radius && d_l[VY] <= rb + obstacle.radius) { //check for possible collision
			float v_mag = (g_fKAvoid * (rb + obstacle.radius - d_l.Length())) / (rb + obstacle.radius );


			vec3 d_x(d_l[VX],0,0);
			vec3 d_y(0,d_l[VY],0);

			vec3 v_avoid = (lb * d_x/d_x.Length() - d_l) / (lb * d_x/d_x.Length() - d_l).Length();

			return v_mag * v_avoid;

		}

	}
	
	return arrive.CalculateDesiredVelocity(actor);
}

