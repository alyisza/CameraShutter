using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(CameraShutterRender), PostProcessEvent.AfterStack, "Custom/Camera Shutter")]
public class CameraShutter : PostProcessEffectSettings
{
    [Range(0f, 1.55f)]
    public FloatParameter scale = new FloatParameter { value = 0.5f };
    [Range(3, 15)]
    public IntParameter segmentCount = new IntParameter { value = 6 };
    public ColorParameter cameraShutterColor = new ColorParameter { value = Color.gray };
    [Range(1, 100)]
    public IntParameter lineWidth = new IntParameter { value = 10 };
    public ColorParameter lineColor = new ColorParameter { value = Color.black };
}
