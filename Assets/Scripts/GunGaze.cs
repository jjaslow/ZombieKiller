using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GunGaze : MonoBehaviour
{
    GameObject eyeCursor;
    [SerializeField] GameObject gunChild;
    GameObject handVisible;


    void Start()
    {
        eyeCursor = GameObject.FindGameObjectWithTag("GazePoint");
    }

    private void Update()
    {
        handVisible = GameObject.FindGameObjectWithTag("HandJoint");
    }


    void LateUpdate()
    {
        if(handVisible==null)
        {
            gunChild.SetActive(false);
            return;
        }

        gunChild.SetActive(true);
        var lookPos = eyeCursor.transform.position - transform.position;
        lookPos.y = 0;
        var rotation = Quaternion.LookRotation(lookPos);
        transform.rotation = rotation;
    }
}
