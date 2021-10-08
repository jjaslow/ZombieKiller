using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureOffset : MonoBehaviour
{
    // Start is called before the first frame update

    [SerializeField] float scrollSpeed = .5f;
    Renderer rend;

    [SerializeField] Texture2D[] textures;


    void Start()
    {
        rend = GetComponent<Renderer>();

        int index = Random.Range(0, textures.Length);
        rend.material.SetTexture("_MainTex", textures[index]);
    }

    void Update()
    {
        float offset = Mathf.Sin(Time.time * scrollSpeed);      //scrollSpeed;
        float offsetY = Mathf.Cos(Time.time * scrollSpeed);      //scrollSpeed;
        rend.material.SetTextureOffset("_MainTex", new Vector2(offset, offsetY));
    }



}


