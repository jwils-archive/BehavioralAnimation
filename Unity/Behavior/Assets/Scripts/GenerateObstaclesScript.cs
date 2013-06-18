using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class GenerateObstaclesScript : MonoBehaviour 
{
	
	//1. Define the struct obstacleParameter

	//2. Write the function signatures for transferObstacleData and clearObstacleData
	
	
	public int obstacleCount = 40; 
	public GameObject[] obstacles;
	
	//3. Include appropriate function calls to transferObstacleData and clearObstacleData
	//in the following code to pass obstacle info to DLL

	void generateObstacles(int count)
	{
		obstacleCount = count;
		obstacles = new GameObject [obstacleCount];
		for(int i = 0; i < obstacleCount; i++)
		{
			// Generates random obstacles
			GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
			Vector3 position = new Vector3(Random.Range(-27.0f, 85.0f), 0, Random.Range(-85.0f, 27.0f));
			float random = Random.Range(2.0f, 6.0f);
			Vector3 scale = new Vector3(random, random, random);
			sphere.name = "Obstacle"+ i;
			sphere.transform.position = position;
			sphere.transform.localScale = scale;
			obstacles[i] = sphere;
		}
	}
	
	void clearObstacles()
	{	 		
 		for(int i = 0; i < obstacleCount; i++)
		Destroy ( GameObject.Find ("Obstacle" + i) );
		obstacleCount = 0;
	}
}
