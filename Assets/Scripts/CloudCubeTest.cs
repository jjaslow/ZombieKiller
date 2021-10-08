using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudCubeTest : MonoBehaviour
{
    [SerializeField] GameObject cubePrefab;

    // Start is called before the first frame update
    //void Start()
    //{
    //    Instantiate(cubePrefab, Camera.main.transform.position + Camera.main.transform.forward, Quaternion.identity);
    //}


    [ContextMenu("Create Sample")]
    public void CreateCube()
    {
        Instantiate(cubePrefab, Camera.main.transform.position + Camera.main.transform.forward, Quaternion.identity);
    }

}
