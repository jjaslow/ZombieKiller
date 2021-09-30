using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grenades : MonoBehaviour
{
    [SerializeField] ZombieCreator zombieCreator;
    AudioSource audioSource;

    private void Start()
    {
        audioSource = GetComponent<AudioSource>();
    }

    public void UseGrenade()
    {
        if (ScoreManager.Instance.GetAvailableGrenades() > 0)
        {
            ScoreManager.Instance.UpdateGrenades(-1);
            zombieCreator.KillAllZombies();
            audioSource.Play();
        }
    }

}
