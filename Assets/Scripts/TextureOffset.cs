using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureOffset : MonoBehaviour
{
    // Start is called before the first frame update

    [SerializeField] float scrollSpeed = .5f;
    Renderer rend;

    [SerializeField] Texture2D[] textures;

    int direction1;
    int direction2;

    void Start()
    {
        rend = GetComponent<Renderer>();

        int index = Random.Range(0, textures.Length);
        rend.material.SetTexture("_MainTex", textures[index]);

        int dirIndex = Random.Range(0, 2);
        direction1 = dirIndex == 0 ? -1 : 1;
        dirIndex = Random.Range(0, 2);
        direction2 = dirIndex == 0 ? -1 : 1;

        float offset = Mathf.Sin(Random.Range(0,1f));      //scrollSpeed;
        float offsetY = Mathf.Cos(Random.Range(0, 1f));      //scrollSpeed;
        rend.material.SetTextureOffset("_MainTex", new Vector2(offset, offsetY));
    }

    void Update()
    {
        float offset = Mathf.Sin(Time.time * scrollSpeed * direction1);      //scrollSpeed;
        float offsetY = Mathf.Cos(Time.time * scrollSpeed * direction2);      //scrollSpeed;
        rend.material.SetTextureOffset("_MainTex", new Vector2(offset, offsetY));
    }



}


