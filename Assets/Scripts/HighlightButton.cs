using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HighlightButton : MonoBehaviour
{
    public Color initialColor;
    public Color highlightColor;
    public Renderer buttonRenderer;
    public int materialNumber;

    // Start is called before the first frame update
    void Start()
    {
        initialColor = buttonRenderer.material.color;
        //highlightColor = Color.red;
    }


    
    public void SetHighlight()
    {
        buttonRenderer.material.color = highlightColor;
    }

    public void UnsetHighlight()
    {
        buttonRenderer.material.color = initialColor;
    }

    private void OnDisable()
    {
        buttonRenderer.material.color = initialColor;
    }


}
