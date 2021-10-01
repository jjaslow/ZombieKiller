// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.MixedReality.Toolkit.Input;
using UnityEngine;

namespace Microsoft.MixedReality.Toolkit.Examples.Demos.EyeTracking
{
    /// <summary>
    /// Destroys the game object when selected and optionally plays a sound or animation when destroyed.
    /// </summary>
    [RequireComponent(typeof(EyeTrackingTarget))]
    public class HitBehaviorDestroyOnSelectjj : MonoBehaviour
    {

        private EyeTrackingTarget myEyeTrackingTarget = null;
        [SerializeField] AudioSource audioSource;


        private void Start()
        {
            myEyeTrackingTarget = this.GetComponent<EyeTrackingTarget>();
            if (myEyeTrackingTarget != null) // Shouldn't be null since we use RequireComponent(), but just to be sure.
            {
                myEyeTrackingTarget.OnSelected.AddListener(ZombieKilled);
            }
        }


        public void ZombieKilled()
        {
            ZombieWalk thisZombie = GetComponentInParent<ZombieWalk>();
            audioSource.Play();
            thisZombie.ZombieKilled();
        }

    }
}