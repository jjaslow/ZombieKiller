using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class ZombieWalk : MonoBehaviour
{
    [SerializeField] float _speed;
    bool canStartWalking = false;
    bool isZombieAlive = true;

    [Space]
    [SerializeField] Transform chestPoint;
    public Animator anim;


    [Space]
    public AudioSource audioSource;
    [SerializeField] List<AudioClip> walkClip;
    [SerializeField] List<AudioClip> attackClip;
    [SerializeField] List<AudioClip> killedClip;

    [Space]
    [SerializeField] SkinnedMeshRenderer smr;
    Camera mainCam;

    Image BloodOverlay;
    Light[] lights;
    Color[] lightColors;

    void Start()
    {
        mainCam = Camera.main;

        smr.enabled = false;

        BloodOverlay = GameObject.FindGameObjectWithTag("RedScreen").GetComponent<Image>();

        lights = GameObject.FindObjectsOfType<Light>();
        lightColors = new Color[lights.Length];
        for (int x=0; x<lights.Length; x++)
        {
            lightColors[x] = lights[x].color;
        }
    }


    void Update()
    {
        if (!canStartWalking)
            return;

        var lookPos = mainCam.transform.position - transform.position;
        lookPos.y = 0;
        var rotation = Quaternion.LookRotation(lookPos);
        transform.rotation = rotation;

        //transform.Translate(Vector3.forward * _speed);
        //TODO HERE
        anim.speed = _speed;

        if (Vector3.Distance(chestPoint.transform.position, mainCam.transform.position) < .875f && isZombieAlive)
            ZombieAttack();

        if (transform.position.y < -50f)
            Destroy(this.gameObject);
    }

    [ContextMenu("CanStartWalking")]
    public void CanStartWalking(float speed)
    {
        smr.enabled = true;

        _speed = speed;

        int clipNumber = UnityEngine.Random.Range(0, walkClip.Count);
        audioSource.clip = walkClip[clipNumber];
        audioSource.Play();

        anim.enabled = true;

        canStartWalking = true;
    }


    [ContextMenu("Zombie Killed")]
    public void ZombieKilled()
    {
        if (!isZombieAlive)
            return;

        ScoreManager.Instance.UpdateScore(1);

        canStartWalking = false;
        isZombieAlive = false;

        anim.speed = 1;
        anim.SetTrigger("Dies");

        //change to zombie dead sound
        audioSource.Stop();
        int clipNumber = UnityEngine.Random.Range(0, killedClip.Count);
        audioSource.clip = killedClip[clipNumber];
        audioSource.loop = false;
        audioSource.Play();

        Destroy(this.gameObject, 5f);
    }



    private void ZombieAttack()
    {
        canStartWalking = false;

        ScoreManager.Instance.RemoveOneLife();

        audioSource.Stop();
        int clipNumber = UnityEngine.Random.Range(0, attackClip.Count);
        audioSource.clip = attackClip[clipNumber];
        audioSource.loop = false;

        anim.speed = 1;
        anim.SetTrigger("Attack");

        
        StartCoroutine(FlashRed());

        Destroy(this.gameObject, 1.75f);
    }

    IEnumerator FlashRed()
    {
        yield return new WaitForSeconds(.5f);

        BloodOverlay.color = new Color32(0, 0, 0, 255);
        for (int x = 0; x < lights.Length; x++)
        {
            lights[x].color = Color.red;
        }

        BloodOverlay.rectTransform.localEulerAngles = new Vector3(0, 0, BloodOverlay.rectTransform.rotation.z + 90);

        audioSource.Play();


        yield return new WaitForSeconds(.5f);

        ResetBloodOverlay();

    }

    public void ResetBloodOverlay()
    {
        BloodOverlay.color = new Color32(0, 0, 0, 0);
        for (int x = 0; x < lights.Length; x++)
        {
            lights[x].color = lightColors[x];
        }
    }

}
