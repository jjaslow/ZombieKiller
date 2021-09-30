using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;



public class ScoreManager : MonoBehaviour
{

    public static ScoreManager Instance { get; private set; }


    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }


    [SerializeField] TMP_Text scoreText;
    [SerializeField] TMP_Text livesText;
    [SerializeField] TMP_Text grenadesText;

    [Space]
    [SerializeField] int startingLives;
    int currentLives;
    int currentScore;
    int grenades;

    private void Start()
    {
        currentScore = 0;
        scoreText.text = "Score: " + currentScore.ToString();

        currentLives = startingLives;
        livesText.text = "Lives: " + currentLives.ToString();

        grenades = 0;
        grenadesText.text = "Grenades: " + grenades.ToString();
    }



    public void UpdateScore(int newPoints)
    {
        currentScore += newPoints;
        scoreText.text = "Score: " + currentScore.ToString();
    }


    public void UpdateGrenades(int change)
    {
        grenades += change;

        grenadesText.text = "Grenades: " + grenades.ToString();
    }

    public int GetAvailableGrenades()
    {
        return grenades;
    }

    public void RemoveOneLife()
    {
        currentLives -= 1;

        if(currentLives==0)
        {
            GameOver();
            return;
        }

        livesText.text = "Lives: " + currentLives.ToString();
    }

    void GameOver()
    {
        livesText.text = "GAME OVER...";

        ZombieCreator zc = FindObjectOfType<ZombieCreator>();
        zc.GameOver();
    }



}
