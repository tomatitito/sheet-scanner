# Cloud Speech API Alternatives Evaluation

**Issue**: `sheet-scanner-8uo` - Evaluate alternative cloud speech APIs  
**Date**: January 2026  
**Status**: Research Complete

## Executive Summary

This document evaluates cloud-based speech recognition APIs as alternatives or complements to OpenAI Whisper API for the Sheet Scanner dictation feature. The evaluation focuses on accuracy for music/classical terminology, pricing, API simplicity, offline fallback options, and privacy considerations.

**Recommendation**: For our music sheet scanning app with specialized classical music terminology, **AssemblyAI** offers the best balance of accuracy, features, and pricing. **Deepgram** is recommended for real-time/streaming use cases due to superior latency.

---

## Current Implementation

We currently use local **Whisper** (via `whisper_flutter_new`) for offline transcription:
- Audio recorded at 16kHz mono WAV format
- Local processing on device
- No cloud API calls (privacy-preserving)

---

## Services Evaluated

### 1. AssemblyAI

**Overview**: Specialized speech-to-text provider with industry-leading accuracy benchmarks.

#### Accuracy
- **Word Accuracy Rate**: 93.32% (Universal model)
- **Word Error Rate**: 6.6% (English) - best in class
- **57% better recognition** of key terms like names, codes, and specialized terminology
- Supports **keyterm prompting** (up to 1,000 words) for domain-specific vocabulary
- **Slam-1 model**: LLM-powered for highest accuracy on specialized content

#### Pricing (January 2026)
| Model | Price |
|-------|-------|
| Universal (pre-recorded) | $0.15/hour |
| Universal Streaming | $0.15/hour |
| Slam-1 (highest accuracy) | $0.27/hour |
| Speaker Diarization | +$0.02/hour |
| Keyterm Prompting | +$0.04/hour |

**Free tier**: $50 credit (~185 hours of transcription)

#### API Simplicity
- Excellent SDKs (Python, JavaScript, Go, Ruby)
- Simple REST API for batch processing
- WebSocket API for streaming (~300ms latency)
- No Flutter SDK, but HTTP/WebSocket integration straightforward

#### Strengths for Music Terminology
- **Keyterm prompting**: Can boost recognition of classical music terms (e.g., "allegro", "fortissimo", "crescendo", composer names)
- **Custom spelling**: Correct domain-specific terms automatically
- **Context-aware**: 1,000-word context window for better accuracy

#### Privacy & Data
- SOC 2 Type II, HIPAA eligible
- EU Data Residency available
- Audio deleted after processing (configurable)
- No data used for model training by default

#### Offline Fallback
- ❌ No offline option (cloud-only)

---

### 2. Google Cloud Speech-to-Text

**Overview**: Enterprise-grade service with Chirp 3 model (latest generation).

#### Accuracy
- **Word Accuracy Rate**: 85.81-90.4% depending on language/dataset
- **Word Error Rate**: ~14% (English) per independent benchmarks
- Chirp 3 model: Enhanced multilingual capabilities

#### Pricing (January 2026)
| Service | Price |
|---------|-------|
| V2 API Standard | $0.016/min ($0.96/hour) |
| V2 API (no data logging) | $0.024/min ($1.44/hour) |
| Dynamic Batch | $0.003/min ($0.18/hour) |
| Medical models | $0.078/min ($4.68/hour) |

**Free tier**: 60 minutes/month

#### API Simplicity
- Comprehensive SDKs (Python, Java, Node.js, Go, C#)
- REST and gRPC APIs
- Flutter integration via REST
- Complex setup with GCP project configuration

#### Strengths for Music Terminology
- **Speech adaptation**: Provide hints to boost specific words
- **Model adaptation**: Train custom models (enterprise)
- **Phrase sets**: Define expected phrases

#### Privacy & Data
- Enterprise-grade security
- Data residency options (EU, US, Asia)
- Customer-managed encryption keys (CMEK)

#### Offline Fallback
- ❌ Cloud-only (no offline containers for Flutter)

---

### 3. Deepgram

**Overview**: Fast inference, developer-friendly API, excellent for real-time applications.

#### Accuracy
- **Nova-3 model**: 5.26% WER (batch), 6.84% WER (streaming)
- **54.2% improvement** over competitors in streaming
- Excellent on noisy audio

#### Pricing (January 2026)
| Model | Pay-As-You-Go | Growth Plan |
|-------|---------------|-------------|
| Nova-3 Streaming | $0.0077/min ($0.46/hr) | $0.0065/min ($0.39/hr) |
| Nova-3 Pre-recorded | $0.0043/min ($0.26/hr) | $0.0036/min ($0.22/hr) |
| Whisper Large | $0.0038/min ($0.23/hr) | $0.0033/min ($0.20/hr) |
| Redaction (add-on) | +$0.0020/min | +$0.0017/min |
| Keyterm Prompting | +$0.0013/min | +$0.0012/min |

**Free tier**: $200 credit

#### API Simplicity
- **Excellent developer experience**
- REST and WebSocket APIs
- Sub-300ms streaming latency (industry best)
- Simple integration, good documentation
- Per-second billing (fair for short clips)

#### Strengths for Music Terminology
- **Keyterm boosting**: Runtime prompting for specific terms
- **Custom models**: Available for enterprise
- Fast model iteration

#### Privacy & Data
- SOC 2 Type II certified
- HIPAA compliant
- Self-hosted deployment available (enterprise)
- EU endpoint available

#### Offline Fallback
- ✅ Self-hosted deployment option (enterprise tier)
- On-premises containers available

---

### 4. Azure Speech Services

**Overview**: Microsoft's enterprise speech platform with extensive language support.

#### Accuracy
- **Word Accuracy Rate**: 91.8% (English benchmarks)
- **Word Error Rate**: ~8.6% (English)
- Good streaming performance

#### Pricing (January 2026)
| Service | Price |
|---------|-------|
| Standard STT | $1/hour |
| Custom STT | Higher (commitment tiers) |
| Whisper (via Azure OpenAI) | $0.36/hour |

**Commitment tiers** for volume discounts:
- 2,000 hours/month: Lower per-hour rates
- 10,000 hours/month: Further discounts
- 50,000 hours/month: Best rates

#### API Simplicity
- Comprehensive SDKs (including mobile)
- REST API
- Good Flutter integration via REST
- Complex Azure setup and authentication

#### Strengths for Music Terminology
- **Custom Speech**: Train custom models with your data
- **Phrase lists**: Boost specific terms
- **Pronunciation assessment**: Useful for practice features

#### Privacy & Data
- Enterprise-grade (Microsoft Trust Center)
- Azure Government cloud available
- GDPR, HIPAA compliant
- Connected/disconnected containers available

#### Offline Fallback
- ✅ **Connected containers**: Run locally, sync to cloud
- ✅ **Disconnected containers**: Fully offline (enterprise, limited access)

---

## Comparison Matrix

| Criteria | AssemblyAI | Google Cloud | Deepgram | Azure |
|----------|------------|--------------|----------|-------|
| **Accuracy (WER)** | 6.6% ⭐ | ~14% | 5.26-6.84% ⭐ | ~8.6% |
| **Price/hour (batch)** | $0.15 | $0.96 | $0.26 ⭐ | $1.00 |
| **Streaming latency** | ~300ms | Variable | <300ms ⭐ | Variable |
| **Music term support** | Excellent ⭐ | Good | Good | Good |
| **API simplicity** | Excellent | Complex | Excellent ⭐ | Moderate |
| **Free tier** | $50 | 60 min | $200 ⭐ | Limited |
| **Offline option** | ❌ | ❌ | Enterprise | Enterprise |
| **Flutter SDK** | ❌ (HTTP OK) | ❌ (HTTP OK) | ❌ (HTTP OK) | ❌ (HTTP OK) |

---

## Music/Classical Terminology Considerations

For accurate transcription of classical music terms, the API should handle:

### Common Terms to Test
- Tempo markings: allegro, andante, adagio, presto, moderato
- Dynamics: fortissimo, pianissimo, crescendo, diminuendo, sforzando
- Articulations: staccato, legato, pizzicato, arco
- Composer names: Beethoven, Tchaikovsky, Rachmaninoff, Debussy
- Italian/German/French terms: rubato, ritardando, accelerando, fermata

### Recommended Approach
1. **Use keyterm prompting** (AssemblyAI/Deepgram) to boost these terms
2. Create a **custom vocabulary list** of 500-1000 music terms
3. **Test with real user recordings** before production deployment
4. Consider **hybrid approach**: local Whisper for basic transcription, cloud API for difficult passages

---

## Pricing Comparison (10 hours/month usage)

| Provider | Monthly Cost | Annual Cost |
|----------|--------------|-------------|
| Deepgram (batch) | $2.60 | $31.20 |
| AssemblyAI | $1.50 | $18.00 |
| Google Cloud | $9.60 | $115.20 |
| Azure | $10.00 | $120.00 |

For light usage (10 hours/month), **AssemblyAI** and **Deepgram** are most cost-effective.

---

## Recommendations

### Primary Recommendation: AssemblyAI
**Best for**: Batch transcription with specialized music terminology

**Why**:
- Highest accuracy with keyterm prompting
- Slam-1 model designed for specialized content
- Competitive pricing ($0.15-0.27/hour)
- Excellent API documentation
- $50 free credit to test

### Secondary Recommendation: Deepgram
**Best for**: Real-time streaming transcription

**Why**:
- Sub-300ms latency (best in class)
- Lowest cost for high volume ($0.26/hour batch)
- Excellent developer experience
- $200 free credit
- Self-hosted option for enterprise

### Keep Current: Local Whisper
**Best for**: Offline-first privacy-preserving transcription

**Why**:
- No cloud costs
- Works offline
- User data stays on device
- Good baseline accuracy

### Proposed Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Dictation Flow                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [User speaks] → [Audio Recording]                          │
│                         │                                   │
│           ┌─────────────┴─────────────┐                     │
│           ▼                           ▼                     │
│    [Offline Mode]              [Online Mode]                │
│    Local Whisper               Cloud API                    │
│    (Fast, Private)             (High Accuracy)              │
│           │                           │                     │
│           └─────────────┬─────────────┘                     │
│                         ▼                                   │
│              [Post-processing]                              │
│         (Music term correction)                             │
│                         │                                   │
│                         ▼                                   │
│              [Display Result]                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Next Steps

1. **Prototype Integration**: Create a simple test with AssemblyAI for music term accuracy
2. **Benchmark**: Compare local Whisper vs AssemblyAI on real music dictation samples
3. **User Setting**: Add option to choose between offline (Whisper) and cloud (AssemblyAI) modes
4. **Keyterm List**: Compile comprehensive list of classical music terms for boosting
5. **Cost Monitoring**: Implement usage tracking to stay within budget

---

## References

- [AssemblyAI Pricing](https://www.assemblyai.com/pricing)
- [AssemblyAI Benchmarks](https://www.assemblyai.com/benchmarks)
- [Google Cloud Speech-to-Text Pricing](https://cloud.google.com/speech-to-text/pricing)
- [Deepgram Pricing](https://deepgram.com/pricing)
- [Deepgram Benchmarks](https://deepgram.com/learn/speech-to-text-benchmarks)
- [Azure Speech Services Pricing](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/)
