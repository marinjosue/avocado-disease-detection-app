/// Código de acceso que desbloquea la IA (candado ligero: filtra usuarios
/// casuales; puede extraerse decompilando el APK — no es seguridad real).
const String kAiAccessCode = '2002';

/// URL directa del modelo Gemma (.litertlm), hosteado como asset público en
/// GitHub Releases (repo marinjosue/avocadoia-models, tag v1.0). La app lo
/// descarga sin token; el nombre del archivo al final de la URL debe coincidir
/// con GemmaModelService.modelFileName.
const String kGemmaModelUrl =
    'https://github.com/marinjosue/avocadoia-models/releases/download/v1.0/gemma3-1b-it-int4.litertlm';
