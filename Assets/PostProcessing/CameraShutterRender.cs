using UnityEngine;
using UnityEngine.Rendering.PostProcessing;


public class CameraShutterRender : PostProcessEffectRenderer<CameraShutter>
{
    public override void Render(PostProcessRenderContext context)
    {
        PropertySheet sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/CameraShutter"));
        sheet.properties.SetFloat("_Scale", settings.scale);
        sheet.properties.SetInt("_SegmentCount", settings.segmentCount);
        sheet.properties.SetInt("_ScreenWidth", Screen.width);
        sheet.properties.SetInt("_ScreenHeight", Screen.height);
        sheet.properties.SetColor("_CameraShutterColor", settings.cameraShutterColor);
        sheet.properties.SetFloat("_LineWidth", settings.lineWidth);
        sheet.properties.SetColor("LineColor", settings.lineColor);

        context.command.BlitFullscreenTriangle(context.source,context.destination, sheet, 0);
    }
}
