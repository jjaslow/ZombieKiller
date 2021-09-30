using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GunGaze : MonoBehaviour
{
    Vector3 gunGazePosition;
    [SerializeField] GameObject eyeCursor;


    void Start()
    {
        eyeCursor = GameObject.FindGameObjectWithTag("GazePoint");
    }


    void LateUpdate()
    {
        var lookPos = eyeCursor.transform.position - transform.position;
        lookPos.y = 0;
        var rotation = Quaternion.LookRotation(lookPos);
        transform.rotation = rotation;
    }
}
