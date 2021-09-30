using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grenades : MonoBehaviour
{
    [SerializeField] ZombieCreator zombieCreator;
    [SerializeField] GameObject explosionPrefab;

    AudioSource audioSource;
    Camera mainCam;

    private void Start()
    {
        audioSource = GetComponent<AudioSource>();
        mainCam = Camera.main;
    }

    [ContextMenu("UseGrenade")]
    public void UseGrenade()
    {
        Debug.Log("tried a grenade");

        if (ScoreManager.Instance.GetAvailableGrenades() > 0)
        {
            ScoreManager.Instance.UpdateGrenades(-1);
            zombieCreator.KillAllZombies();
            audioSource.Play();
            PlayExplosionParticle();
        }
    }

    [ContextMenu("UseGrenadeParticleOnly")]
    void PlayExplosionParticle()
    {
        Vector3 particlePosition = mainCam.transform.position + (mainCam.transform.forward*5f);
        Vector3 floorPosition = zombieCreator.GetFloorPosition();
        particlePosition.y = floorPosition.y + .5f;

        GameObject newParticle = Instantiate(explosionPrefab, particlePosition, Quaternion.identity);
        Destroy(newParticle, 3.5f);
    }

}
