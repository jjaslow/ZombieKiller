using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HighlightButton : MonoBehaviour
{
    public Color initialColor;
    Color initialColorBackup;
    public Color highlightColor;
    public Renderer buttonRenderer;
    public int materialNumber;

    // Start is called before the first frame update
    void Start()
    {
        initialColor = buttonRenderer.material.color;
        initialColorBackup = initialColor;
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

    public void SetSecondaryInitialColor(Color secondaryColor)
    {
        initialColorBackup = initialColor;
        initialColor = secondaryColor;

        if(buttonRenderer.material.color != highlightColor)
            buttonRenderer.material.color = initialColor;
    }

    public void ClearSecondaryInitialColor()
    {
        initialColor = initialColorBackup;
    }

}
