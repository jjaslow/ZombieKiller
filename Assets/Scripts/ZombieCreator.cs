using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ZombieCreator : MonoBehaviour
{
    Camera mainCam;

    [SerializeField] GameObject zombiePrefab;
    [SerializeField] GameObject floorCenterPrefab;
    GameObject floor;
    Vector3 floorPosition;

    float zombieWalkSpeed;
    float zombieRepeatTime;
    int zombiesCreated = 0;
    bool createZombies = true;

    [Space]
    [SerializeField] int grenadeFrequency = 5;

    void Start()
    {
        mainCam = Camera.main;
    }

    [ContextMenu("Start Zombies")]
    public void StartZombies()
    {
        floor = Instantiate(floorCenterPrefab, mainCam.transform.position, Quaternion.identity);

        zombieWalkSpeed = 1f;
        zombieRepeatTime = 5f;

        StartCoroutine(InvokeZombie());
    }

    IEnumerator InvokeZombie()
    {
        yield return new WaitForSeconds(3f);

        floorPosition = floor.transform.position;
        Destroy(floor);


        while (createZombies)
        {
            //Vector3 newPos = mainCam.transform.position + (mainCam.transform.forward * .1f) + (mainCam.transform.up * .1f);
            GameObject newZombie = Instantiate(zombiePrefab, floorPosition, Quaternion.identity);
            yield return new WaitForSeconds(.5f);

            //if (newZombie.transform.position.y >= mainCam.transform.position.y)
            //    Destroy(newZombie);

            Rigidbody rb = newZombie.GetComponent<Rigidbody>();
            //rb.useGravity = false;
            Destroy(rb);

            Collider col = newZombie.GetComponent<Collider>();
            //col.isTrigger = true;
            //col.enabled = false;
            Destroy(col);



            float scale = Random.Range(3f, 5f);
            int direction = Random.Range(0, 2);
            scale *= direction == 0 ? 1 : -1;
            newZombie.transform.Translate(Vector3.right * scale, Space.World);

            scale = Random.Range(3f, 5f);
            direction = Random.Range(0, 2);
            scale *= direction == 0 ? 1 : -1;
            newZombie.transform.Translate(Vector3.forward * scale, Space.World);

            newZombie.GetComponent<ZombieWalk>().CanStartWalking(zombieWalkSpeed);

            yield return new WaitForSeconds(zombieRepeatTime);
            zombiesCreated++;
            MakeZombiesAppearFaster();
            AddGrenades();
        }
    }

    void MakeZombiesAppearFaster()
    {
        if (zombiesCreated % 5 == 0)
        {
            zombieRepeatTime -= .5f;
            zombieWalkSpeed += .1f;
        }

        if (zombieRepeatTime <= 2f)
        {
            zombieRepeatTime = 2f;
        }
    }

    void AddGrenades()
    {
        if (zombiesCreated % grenadeFrequency == 0)
            ScoreManager.Instance.UpdateGrenades(1);
    }


    public void GameOver()
    {
        createZombies = false;

        KillAllZombies();
    }

    public void KillAllZombies()
    {
        ZombieWalk[] existingZombies = FindObjectsOfType<ZombieWalk>();
        foreach (var zombie in existingZombies)
        {
            zombie.ResetBloodOverlay();
            Destroy(zombie.gameObject);
        }
    }

    public void UserQuits()
    {
        Application.Quit();
    }

}
