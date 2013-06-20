#include "stdafx.h"
#include "Wander.h"
#include <math.h>

float Wander::g_fKNoise = 10.0;
float Wander::g_fKWander = 100.0;

Wander::Wander() : Behavior("wander"), m_vWander(0.0, 0.0, 0.0)				   
{
}

Wander::~Wander()
{
}
Wander::Wander(vec3 mvw) : Behavior("wander"), m_vWander(mvw[0], mvw[1], mvw[2])
{
}
Wander::Wander(const Wander& orig) : Behavior(orig), m_vWander(orig.m_vWander)
{
}

Behavior* Wander::Clone() const
{
    return new Wander(*this);
}

// Given the actor, return a desired velocity in world coordinates
// Wander returns a velocity whose direction changes at random
vec3 Wander::CalculateDesiredVelocity(Actor& actor)
{
	// find a random direction
	vec3 n(rand(),rand(),rand());
	

    // scale it with a noise factor
	n = g_fKNoise * n.Normalize();
	// change the current velocity to point to a random direction
   
	vec3 v_w = g_fKWander * n;
	// scale the new velocity	

	return actor.linearVelocity + v_w;
}
