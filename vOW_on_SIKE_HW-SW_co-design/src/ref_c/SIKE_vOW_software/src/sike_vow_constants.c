// Definition of instances and constants to run attack on SIKE

#include "instance.h"

#if defined(P128)

#if defined(p_32_20)
instance_t insts_constants = {
     .MODULUS = "p_32_20",
     .e = 16,
     .ALPHA = 2.25,
     .BETA = 10.,
     .GAMMA = 10.,
     .PRNG_SEED = 1337,
     .NBITS_STATE = 15,    // log(S) = e-1, it should hold NBITS_STATE > MEMORY_LOG_SIZE
     .NBYTES_STATE = 2,
     .NWORDS_STATE = 1,    // Assuming 64-bit words
     .NBITS_OVERFLOW = 7,
     .MAX_STEPS = 36,      // ceil(10 / THETA), where THETA = 2.25 * sqrt(w / S)
     .MAX_DIST = 5120,     // BETA * w;
     .MAX_FUNCTION_VERSIONS = 100000,
     .DIST_BOUND = 18,     // Floor(THETA * 2^(e-1 - log(w)));
     .STRAT = {3, 2, 1, 1, 1, 1},
     .jinv = {0xB12094B4902203E9, 0x0, 0xD4A5907EE6A3B76E, 0x3},
     .ES = {
           {
           .a24 = { 0x94f6492e6689d498, 0x000000000000011, 0xac0e7a06ffffffff, 0x000000000000012  },
           .xp  = { 0xba35363e27719982, 0x000000000000000, 0xac0e7a06ffffffff, 0x000000000000012 },
           .xq  = { 0xbdead271abe4003d, 0x00000000000001a, 0xac0e7a06ffffffff, 0x000000000000012 },
           .xpq = { 0xa120c624d1d26ee6, 0x000000000000019, 0xb69a53c8034ac449, 0x000000000000006 },
           },
           {
           .a24 = { 0x8fc977c3823485fd, 0x000000000000020, 0xac0e7a06ffffffff, 0x000000000000012 },
           .xp  = { 0x63aaff2b78a93264, 0x000000000000011, 0xd90e8f13c1b09ab8, 0x000000000000006 },
           .xq  = { 0x14e6539d176a5d80, 0x000000000000002, 0xac0e7a06ffffffff, 0x000000000000012 },
           .xpq = { 0x63aaff2b78a93264, 0x000000000000011, 0xd2ffeaf33e4f6547, 0x00000000000000b },
           }},
     .EE = {
           .a24 = { 0xfddd09f3ea73121c, 0x000000000000019, 0x4c37aac90d494a48, 0x000000000000007 },
           .xp  = { 0x61890647112ff628, 0x000000000000013, 0x23ac49d09763cc61, 0x000000000000004 },
           .xq  = { 0x6e48b899c772ea13, 0x000000000000005, 0xd1bf6743c9d5bad1, 0x000000000000010 },
           .xpq = { 0xa8a26ba9b4f88a14, 0x000000000000006, 0x4bf891056b7213a4, 0x000000000000003 },
           }};

#define NBITS_STATE  15
const f2elm_t64 DBL_TABLE_ES[2*2*(NBITS_STATE+1)] = { // A point per row represented in (X:Z) coordinates
{ 0x11DC586AABE4003E, 0x08, 0x0000000000000000, 0x00 }, { 0xD9FEFBEAD8BA0D2B, 0x04, 0x0000000000000000, 0x00 },
{ 0x7241169338C98BDA, 0x0E, 0x0000000000000000, 0x00 }, { 0x808EE7F55C96C0FD, 0x11, 0x0000000000000000, 0x00 },
{ 0xEC2454D96F81AD76, 0x00, 0x0000000000000000, 0x00 }, { 0xB3D5021D016956B5, 0x08, 0x0000000000000000, 0x00 },
{ 0x58C7F25591292930, 0x00, 0x0000000000000000, 0x00 }, { 0xF0C633FD0150BA5A, 0x11, 0x0000000000000000, 0x00 },
{ 0xDED71AC828535F9C, 0x10, 0x0000000000000000, 0x00 }, { 0xAA7CB5A656CA577C, 0x0F, 0x0000000000000000, 0x00 },
{ 0x0BB8556476D434D8, 0x0D, 0x0000000000000000, 0x00 }, { 0x39593BCF129B2649, 0x11, 0x0000000000000000, 0x00 },
{ 0xC171B8F8F84D5988, 0x07, 0x0000000000000000, 0x00 }, { 0x9ED1E28F1561AFAE, 0x02, 0x0000000000000000, 0x00 },
{ 0x864DCC7855CBDAAB, 0x12, 0x0000000000000000, 0x00 }, { 0x23482F7DD1724613, 0x09, 0x0000000000000000, 0x00 },
{ 0xAB8ED2DF4CAC6C75, 0x0C, 0x0000000000000000, 0x00 }, { 0x3999A22937B3DE88, 0x02, 0x0000000000000000, 0x00 },
{ 0xFCFB5F2D9951B773, 0x01, 0x0000000000000000, 0x00 }, { 0x68B32C64460ECC87, 0x10, 0x0000000000000000, 0x00 },
{ 0x15EA8B17B7A34506, 0x08, 0x0000000000000000, 0x00 }, { 0x6F23DB4E32FB0169, 0x03, 0x0000000000000000, 0x00 },
{ 0xB89BAAFCDC5978F5, 0x03, 0x0000000000000000, 0x00 }, { 0x705421D31B22CC1E, 0x0B, 0x0000000000000000, 0x00 },
{ 0x42EE3F545CDE53BF, 0x07, 0x0000000000000000, 0x00 }, { 0x69203AB2A321AC40, 0x0B, 0x0000000000000000, 0x00 },
{ 0x0000000000000000, 0x00, 0x0000000000000000, 0x00 }, { 0x1B6523251B6C3920, 0x07, 0x0000000000000000, 0x00 },
{ 0x1132454F24B2979D, 0x0B, 0x0000000000000000, 0x00 }, { 0x0000000000000000, 0x00, 0x0000000000000000, 0x00 },
{ 0x2258FF066B30CD87, 0x0C, 0x0000000000000000, 0x00 }, { 0x0000000000000000, 0x00, 0x0000000000000000, 0x00 },

{ 0x14E6539D176A5D80, 0x02, 0x0000000000000000, 0x00 }, { 0xD9FEFBEAD8BA0D2B, 0x04, 0x0000000000000000, 0x00 },
{ 0x0CD0AEB59BC38E2E, 0x04, 0x0000000000000000, 0x00 }, { 0xF167A3CF27F98C84, 0x07, 0x0000000000000000, 0x00 },
{ 0xCA50AC7375F401D4, 0x03, 0x0000000000000000, 0x00 }, { 0x6CA88DC25A91A68D, 0x0E, 0x0000000000000000, 0x00 },
{ 0x1A3B9F4336744314, 0x10, 0x0000000000000000, 0x00 }, { 0x56179E60B6F66D02, 0x00, 0x0000000000000000, 0x00 },
{ 0x1E9D7BBBE93CAE9D, 0x07, 0x0000000000000000, 0x00 }, { 0xA38E1D059591F741, 0x05, 0x0000000000000000, 0x00 },
{ 0x7AFCD01C39CCB361, 0x00, 0x0000000000000000, 0x00 }, { 0xE1A828A0BF22112C, 0x0D, 0x0000000000000000, 0x00 },
{ 0x83205B3A993C370E, 0x0F, 0x0000000000000000, 0x00 }, { 0xB192493F4B01A802, 0x0B, 0x0000000000000000, 0x00 },
{ 0xB4A73879EBEF8A27, 0x10, 0x0000000000000000, 0x00 }, { 0xED2828EC2AA11D3F, 0x0F, 0x0000000000000000, 0x00 },
{ 0xFEE17FF18AEC5308, 0x02, 0x0000000000000000, 0x00 }, { 0xDEF99173C458156F, 0x11, 0x0000000000000000, 0x00 },
{ 0xD2762D5C46948964, 0x0E, 0x0000000000000000, 0x00 }, { 0xEF9CEE203DA012E6, 0x0E, 0x0000000000000000, 0x00 },
{ 0x3ADAB4887E09D586, 0x0F, 0x0000000000000000, 0x00 }, { 0xDCA4BCF550617E41, 0x0E, 0x0000000000000000, 0x00 },
{ 0x49A8DD080A9753BF, 0x0F, 0x0000000000000000, 0x00 }, { 0x5FDD2D8703A4C0E5, 0x07, 0x0000000000000000, 0x00 },
{ 0xC2D52426C249F80A, 0x04, 0x0000000000000000, 0x00 }, { 0xE93955E03DB607F5, 0x0D, 0x0000000000000000, 0x00 },
{ 0x0000000000000000, 0x00, 0x0000000000000000, 0x00 }, { 0x1326619B0E5E2DF0, 0x05, 0x0000000000000000, 0x00 },
{ 0x3283B26FD6B97E06, 0x01, 0x0000000000000000, 0x00 }, { 0x0000000000000000, 0x00, 0x0000000000000000, 0x00 },
{ 0x20A958134D6E3FA7, 0x0E, 0x0000000000000000, 0x00 }, { 0x0000000000000000, 0x00, 0x0000000000000000, 0x00 },
};
const f2elm_t64 DBL_TABLE_EE[2*(NBITS_STATE+1)] = { // A point per row represented in (X:Z) coordinates
{ 0x6e48b899c772ea13, 0x05, 0xd1bf6743c9d5bad1, 0x10 }, { 0xD9FEFBEAD8BA0D2B, 0x04, 0x0000000000000000, 0x00 },
{ 0x30319E14CBDC646C, 0x10, 0x4C5D8EBA1F02C944, 0x01 }, { 0x06EBCB2BF5AC1450, 0x05, 0xFACC1921C17FA75E, 0x11 },
{ 0xDAD68F01F525BA7E, 0x0C, 0x13D50BDFD92B7CC5, 0x0A }, { 0xD815125EE168EFB4, 0x02, 0x23720821D8F494DB, 0x0A },
{ 0xCEFA6DE6B18F5FEE, 0x0D, 0x8B37A518D5EDB213, 0x0E }, { 0xC345819FD645389C, 0x0A, 0x397F7661857D25D8, 0x11 },
{ 0x36A35A2EBEF97D33, 0x0C, 0x20089C09CD4C6371, 0x10 }, { 0x35A61BE9C3BD1F34, 0x08, 0x706155B62EFD77E7, 0x02 },
{ 0xA33C4CF0E8BAFF41, 0x03, 0x01ACF5CC182702EF, 0x0A }, { 0x7219C88AEBC2FF3C, 0x00, 0x6E1C22E23807BF51, 0x05 },
{ 0x19274C068308F028, 0x00, 0x456690A23EDF6ACB, 0x06 }, { 0xBBBFFD9D660A85E0, 0x06, 0x6E2B7BC17EF0F4E6, 0x01 },
{ 0xAC3DB02DD7938F51, 0x08, 0xC09DBD65DBD6A9D5, 0x04 }, { 0x1EFAF447F59ECDE6, 0x06, 0x530CFE9F2BFDFDA4, 0x11 },
{ 0x69DADC8F7E5A021F, 0x00, 0xBBF98DF30C51CC1E, 0x0C }, { 0xD364B5EDCFCDDCBC, 0x0E, 0x93B9F750A983877D, 0x05 },
{ 0x663304C0F9ECC827, 0x02, 0x1A5B6957FA429312, 0x0F }, { 0x27ADF35FE5FEFE3D, 0x11, 0xC5B4AA8DAC99F5B5, 0x0D },
{ 0x9CDC16D01535C018, 0x03, 0x7978AFEE37C160CD, 0x0C }, { 0xA5474F772E221B4F, 0x11, 0xF1AAEB216045B3C6, 0x03 },
{ 0x794E56868E5E3ABD, 0x04, 0x1021B8ADADEB10CB, 0x12 }, { 0xF5E251C1DDB79F68, 0x0E, 0x5AAF81CB705A5968, 0x0C },
{ 0xC88289470BF270FC, 0x09, 0x288C5A8150A777B0, 0x05 }, { 0xC88289470BF270FC, 0x09, 0x288C5A8150A777B0, 0x05 },
{ 0x0000000000000000, 0x00, 0x0000000000000000, 0x00 }, { 0x393228DC210C9368, 0x01, 0x39B6003388DA64E9, 0x06 },
{ 0xA1E1A94BB68FA9C6, 0x02, 0xB0879C5B2CB840A1, 0x0A }, { 0x0000000000000000, 0x00, 0x0000000000000000, 0x00 },
{ 0xE80B5BD09398059F, 0x0E, 0x22A1649F4D2F5F6A, 0x05 }, { 0x0000000000000000, 0x00, 0x0000000000000000, 0x00 },
};

     /*
     .delta = 14,
        .jinv = { 0xAB06C85C1303E5D4, 0x9, 0xA9BBFD04E961CD84, 0xA },
        .E = {
            {
            .a24 = { 0xB3FDF7D5B1741A56, 0x9, 0x0, 0x0 },
            .xp = { 0xC0C9A6AC4D13161D, 0xC, 0x0, 0x0 },
            .xq = { 0xFA19DF1C8EAD197C, 0x1, 0x0, 0x0 },
            .xpq = { 0xEC17EE5D86A3C4AF, 0xC, 0x7462B6D56FC8FD8A, 0x1 },
            },
            {
            .a24 = { 0x79B8E34104E2B6A7, 0x0, 0x69DBE7A858780B75, 0x0 },
            .xp = { 0xC0B95427B675D3D3, 0x8, 0xD19CA8500856EABC, 0xE },
            .xq = { 0x27D8D4C9DD2EF013, 0x9, 0xCDC81B7985F7E969, 0xA },
            .xpq = { 0x60917A49A2D09A0, 0xC, 0x965E6A0D6F128B3A, 0x11 },
         }}};
       */
#elif defined(p_36_22)
instance_t insts_stats = {
     .MODULUS = "p_36_22",
     .e = 18,
     .ALPHA = 2.25,
     .BETA = 10.,
     .GAMMA = 10.,
     .PRNG_SEED = 1337,
     .delta = 16,
     .jinv = {0x746F73A9CFAA13E5, 0xC55, 0x7A1E90E1166968FA, 0x124},
     .E = {
         {
             .a24 = {0xD1707E4C49EAFA66, 0x90C, 0x0, 0x0},
             .xp = {0x682B62853F71D736, 0x4EA, 0x0, 0x0},
             .xq = {0x9D038855DB13E7EC, 0xB15, 0x0, 0x0},
             .xpq = {0x47F5F56308F748CF, 0x48A, 0x629A10A84F171B70, 0xDD8},
         },
         {
             .a24 = {0x278AB12BB23B5554, 0x59B, 0xA2C752E877CD7B91, 0x72F},
             .xp = {0xAECDC850C7C72C1C, 0xE23, 0xFC28CEDB420B686E, 0x25},
             .xq = {0x8A2CDD104BA6C91D, 0x42A, 0xBD769AC24549DFB3, 0xC90},
             .xpq = {0xC67C1B31A4C13D83, 0xDB6, 0xF73D3573EFEBD873, 0x7BD},
         }}};
#else
    #error "Selected P128 prime is not supported... "
#endif

#elif defined(P377)

instance_t insts_stats = {
     .MODULUS = "p_191_117",
     .e = 20,
     .MEMORY_LOG_SIZE = 10,
     .ALPHA = 2.25,
     .BETA = 10.,
     .GAMMA = 20.,
     .PRNG_SEED = 1337,
     .delta = 0,
        .jinv = { 0xB8D5636F59F87BFA, 0xDC09D929795E4C5D, 0x95C6C7DFA2CBA665, 0x2C16F3A36D33AD28, 0xC8710F5CECFBE735, 0xFA18952E4885E7, 0x5854C8F67347A874, 0xC606D980BD107B0F, 0xD56322F8C990030A, 0x6563EFD1EFBDCC02, 0x59FCBB041C8447AD, 0x1182CE3831C5304 },
        .E = {
            {
            .a24 = { 0x179, 0x0, 0x8000000000000000, 0x64AFEAD4E5A677F2, 0xE4A1F89587E9FB22, 0x57CC2FD81A8921, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xp = { 0xB2B0570A25D30884, 0x8BF968CC29DBAB59, 0x5E6F419958F025D, 0xCDD5BA6352E7FB82, 0xA9E18BB3509FD837, 0xAB51B341AA68F0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xq = { 0x109AF9C1DB0C655E, 0xD61868C2F02A162B, 0x910EAC74218A8FB8, 0x13CCF89600AD71A5, 0x8B4E3031852FB140, 0xF46CB86F54604D, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xpq = { 0xDB3F693EB3BDB406, 0xAE3E06304F07BFC, 0x69CB6CC85A47BBB8, 0xBF073D03B8E4EAAC, 0xD287368775898397, 0x1373DBF65614E6B, 0x63E5E9D0542EBDED, 0xE654124F56B3BB95, 0xA4DED0B6CBE9D89, 0x8FF0ABA02F2C86D9, 0x2213C5F18BE60FA6, 0x1595E82901E477F },
            },
            {
            .a24 = { 0x6CEA7D744AE8AB2D, 0xC03114B6E9DD1930, 0x22D9B8B946077116, 0x30DBB255E907B373, 0xFE5BBB225F59A14E, 0xDB596E36BAC925, 0xA5148B73BB208630, 0x3AF52698431B2E57, 0xB639B0A6C18B2D8, 0xEC2C09BE677ACCE4, 0xD3E456EF46BCBB8F, 0xBA7D123C0D8D2 },
            .xp = { 0x4F5ED3A6CA604957, 0x3B9E3513F6D0482D, 0x8499BFFF7D6F9CB8, 0x9208202CEF642E65, 0xD39996EBE7BA975F, 0x14A320DAF945062, 0x5AAABBF9572FE9D6, 0x7765615482C95128, 0x8F970ED4F05B329B, 0x5B05B0CE759227BA, 0xF722D470F9F79EFF, 0x5ACDEE4D064CE5 },
            .xq = { 0xAB80D338F01EA13D, 0xA1B79A7AEE78C856, 0x305CD19A55119D44, 0x66CBDD84475EBFC8, 0xC7B576DE571916D, 0x11293D09AE63829, 0xE3F703003DECA4B5, 0xE858359D9E108F84, 0x7318C325D847284D, 0x904B38878CB15604, 0xD92BE87CD18C69BB, 0x14C2099F3A3E702 },
            .xpq = { 0x19215348465394C3, 0x15630D6CD9C7E31E, 0x7EBE81C6A0C8E2, 0x63DB1A4981DB17C, 0x3B3FEB23A57823C4, 0x682AE5121657C0, 0xD02BB8C33D10EB1D, 0x5B76D9F5C799709, 0xFB378596E3BA58C0, 0x9C0DE5608BE8F442, 0x9DE466F12E03598F, 0xAC8F7DEAB96A7C },
     /*
     .e = 95,
     .MEMORY_LOG_SIZE = 20,
     .ALPHA = 2.25,
     .BETA = 10.,
     .GAMMA = 20.,
     .PRNG_SEED = 1337,
     .delta = 0,
        .jinv = { 0xE99AA45538E16BBC, 0xD837D7D58ACC8835, 0x7D0633D925B2DF93, 0x6255DAFE4FE90161, 0x72F43DB48A8221B9, 0x14D510E00159BBD, 0x7EDFE17D5E3C6742, 0xD31E6AAB0E8B63FA, 0x9B644EE10003679F, 0xC649D7DFB70B7664, 0x76A5EC2D87405D54, 0xDA3E9969C792C4 },
        .E = {
            {
            .a24 = { 0x179, 0x0, 0x8000000000000000, 0x64AFEAD4E5A677F2, 0xE4A1F89587E9FB22, 0x57CC2FD81A8921, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xp = { 0x29FD313FACC0EF64, 0x7477EB47CB1E843B, 0x397412EB3E270201, 0x91C59E9B59B6126D, 0x3FFB8FE546AFBC28, 0x7172479FCD6332, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xq = { 0xE878505C7F082C53, 0xC4C331FA7A4368B2, 0x335657A4BD418727, 0xF11294F46FB7FC33, 0x446F9B611AD7119C, 0x1D7F2939FDBC6, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xpq = { 0xDA74DF1D9F84CA0F, 0x4C8BA006AD4FBD4C, 0x866585A45E0391CE, 0xDD087E830AC1FA26, 0x3C29408F4BDAFA0B, 0x10AFCA6F6BE911C, 0x45C060188E6EA134, 0xD7FACE9F53F73662, 0xCCF26AB684F35E93, 0x1FF71FB718E69E67, 0x5E137FEE4FEFA70B, 0x158CD770B8F6F7D },
            },
            {
            .a24 = { 0x5F53A7A796C6B993, 0x6696F89559F80E83, 0x62D9A3C9DC883700, 0xE1FBAF3B57FDDF49, 0xF7B8010A66FA2FC6, 0x1269954554F8C72, 0x231EF08C477C98BF, 0xD5E9EC91510D035C, 0xD831AE3A132B669A, 0x3FF5088CF9F9106A, 0x11B1158202073E81, 0x6C368C4BA69A2B },
            .xp = { 0x93A91F524AFA9CA8, 0xA7F74C6E171DEF0F, 0x8A353449832B127, 0x8450B146E665D9C4, 0x9888D42BC8AF4E7A, 0xD8B6645AC3AFC, 0x830BF6B6E30316BF, 0xC73C8F39EE81753D, 0xC3F95050C1612686, 0x57862A1AB3F62D3C, 0x9C721F01232E5F55, 0x1368E94DB899809 },
            .xq = { 0x97BD419AE2C26CB0, 0x355153E802482C2, 0xEA444A074715C818, 0x2495D09A15E9096, 0x984D7A009F970F9C, 0x489946C06EDDA8, 0xCBA733CBA449B98B, 0xFFB4790756383FA4, 0x9CC4C28ADCF5CAEE, 0x87BCB99CEB4E6EE5, 0x35D9EFE2D0F53929, 0x92629F048DD9F7 },
            .xpq = { 0x50739A401FC65C8A, 0x11FB41B2CF975E9E, 0x73BC885D7A42861D, 0xDF20D8ED0A7B89EB, 0x471B8522A1BAEFB9, 0xC92ADB6FE9D453, 0x37286180BBB780A2, 0x90B57BEB5C1A4E93, 0x6E5F43C179BABD36, 0x4D1926246587097C, 0x95F5EA0DADBEBCC7, 0x81F47629550C90 },
         */
         }}};

#elif defined(P434)

instance_t insts_constants = {
     .MODULUS = "p_216_137",
     .e = 20,
     .MEMORY_LOG_SIZE = 10,  // log(w)
     .MEMORY_SIZE = 1024,    // w = 2^log(w), limited to 32-bit
     .ALPHA = 2.25,
     .BETA = 10.,
     .GAMMA = 20.,
     .PRNG_SEED = 1337,
     .NBITS_STATE = 19,  // log(S) = e-1
     .NBYTES_STATE = 3,
     .NWORDS_STATE = 1,  // Assuming 64-bit words
     .NBITS_OVERFLOW = 5,
     .MAX_STEPS = 202,   // ceil(20 / THETA), where THETA = 2.25 * sqrt(w / S)
     .MAX_DIST = 10240,  // BETA * w;
     .MAX_FUNCTION_VERSIONS = 100000,
     .DIST_BOUND = 50,   // Floor(THETA * 2^(e-1 - log(w)));
     .jinv = { 0xB3615B60239B60AE, 0xD810908B5792BD90, 0x2956DC681E074961, 0x5AEDBDC0E9DF1FA4, 0x9C88E9B42FB9CF85, 0xA0307915481A4AF2, 0x419E4947A299, 0x866D6D2CDC302AB2, 0xF57D4F6971341C2, 0x9E3A07D84DB077C7, 0x5FB74938CB8AE25D, 0x8C1EFD76ECFC9399, 0x8F801F4C004DB5A3, 0x4294646E7ADF },
     .ES = {
           {
           .a24 = { 0xc6a8a338d646ffd0, 0xb38b31ec581c87de, 0xf712b7dd49b0aa2a, 0x9ffedf860908f3c0, 0xca88b4c84add276e, 0x2b7aad996e337658, 0x00006058bcfd64bc, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xfdc1767ae2ffffff, 0x7bc65c783158aea3, 0x6cfc5fd681c52056, 0x0002341f27177344 },
           .xp = { 0x6deaa00c9832c2fa, 0xabd4092bca5e2be8, 0xcc14f7a0715a3226, 0x1cc97b11e7a28cc7, 0x4de848aebc2cb3c1, 0x168a7154fd0c56ee, 0x0001c6e243f1e13c, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xfdc1767ae2ffffff, 0x7bc65c783158aea3, 0x6cfc5fd681c52056, 0x0002341f27177344 },
           .xq = { 0x1abf0ad9000a2be7, 0x42f63f7580774525, 0x931a7c3f9fb46bfa, 0x5cb849b298d6164f, 0xe774b7eae06702c7, 0x45e811bc2d999d22, 0x0002396c92612e14, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xfdc1767ae2ffffff, 0x7bc65c783158aea3, 0x6cfc5fd681c52056, 0x0002341f27177344 },
           .xpq = { 0x059a6444fec74673, 0x4326c287febed6d8, 0x13fe1ad4ac394b1f, 0xbdbaab39f9bdba03, 0xfc4d7997d792921f, 0x4b91e6572aba0cfc, 0x00005bfdcf6b869b, 0x56a53de8fd7c906d, 0xa56e393146214834, 0x4a164e6ea297392d, 0xeb201b2d34b596b1, 0x36a6184257c707eb, 0xcb27bf1c0d259288, 0x00011b4b2a4e8971 },
           },
           {
           .a24 = { 0x39575cc729aa7aa2, 0x4c74ce13a7e37821, 0x08ed4822b64f55d5, 0x1e971a92e0f70c3f, 0xfa1bba5fb406caf2, 0xa4080595bbac2cc6, 0x0000db866ea50da4, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xfdc1767ae2ffffff, 0x7bc65c783158aea3, 0x6cfc5fd681c52056, 0x0002341f27177344 },
           .xp = { 0x3e12ec44b912d68b, 0xb97e423453d27fbb, 0x46667fe6246b7dec, 0x50b92d24dd77d0f2, 0xc08454f060a65310, 0x941a0d2833d1719f, 0x0000bb7c6bf49b72, 0xc7b8cf4bbbcbda85, 0x93f0d081ea485c36, 0x05951a7ad2264410, 0x86afbffcd4744641, 0x7bbd3b75afa2bad2, 0x293c589bc864b4cf, 0x000150df950810f6 },
           .xq = { 0x9b64d02b66cd2bd1, 0x36c92aae135b99b6, 0x41bda196ce5ed8f4, 0x9391b7dfe9afc39f, 0xa62d254da1b421d6, 0x5b683c81d0f43e89, 0x00028b08f06baede, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xfdc1767ae2ffffff, 0x7bc65c783158aea3, 0x6cfc5fd681c52056, 0x0002341f27177344 },
           .xpq = { 0x3e12ec44b912d68a, 0xb97e423453d27fbb, 0x46667fe6246b7dec, 0x4e7aa39fc077d0f2, 0x3c4ab16891ff01b4, 0x01166cfeb59691f6, 0x0002ef9b930c0eb7, 0x384730b44434257a, 0x6c0f2f7e15b7a3c9, 0xfa6ae5852dd9bbef, 0x7711b67e0e8bb9be, 0x0009210281b5f3d1, 0x43c0073ab9606b87, 0x0000e33f920f624e },
           }},
     .EE = {
           .a24 = { 0x9c405af88f658ab9, 0xa30fd309b2dc8252, 0xcd790a74ccfe2abb, 0x09662e3fe9013c36, 0x0790ee4fcc377a4a, 0x30de2c1b53bbc814, 0x0000dd6814faeb26, 0x67bcbee7f01555bb, 0x318745f0157360fb, 0xef06cf33b7e745b5, 0x0bd9373915258a06, 0x4fbbb57cae13c1f7, 0x600095e49dc3008c, 0x0001855bf0fc28e9 },
           .xp = { 0xd56cbfc4af053c0c, 0x8b969f613780a3f5, 0x61fdb8b622148436, 0x9934e63d3801c936, 0x466cef34835b3862, 0x8ef57363d8ee1de1, 0x0000c304f41844b8, 0x7b078acafc7b1af5, 0x85261124522f5cda, 0xc6e1e3372255755d, 0x7dfc8612a601c8a0, 0xb3e11de5f8804992, 0xb26f1a35a8bff2d1, 0x00005d771c1d3f05 },
           .xq = { 0x2f1f83597594e6ef, 0xe5f12a7cd2897020, 0x38d266f7e55fd782, 0xc86fe851e30c81c8, 0xd898e46a293c8631, 0x824d6b3e215066bb, 0x000173ab9f30b497, 0x8e0ce01eb56d88c6, 0xf60db6f9e851a69c, 0x5f0ed186a07f7948, 0x1f8890c1f6bea7c3, 0xf24bb2ff054b2c20, 0xa491343a2efaa863, 0x00017faadb85e3d4 },
           .xpq = { 0xd36e67afa6fb3c9e, 0x0a7c8fc0279695ca, 0xc40df8fb1a3119c3, 0xb400c1a3012e0fbf, 0xa94dab3c059ca311, 0x3548011a99fe57bb, 0x00002f961103f981, 0xa60af982a24365be, 0x1330a88f83ba7fb9, 0x68ea888c3d2bdb2f, 0x89cc668ab462b13a, 0xb607a160801e375b, 0x33c19029698a9e4e, 0x00004ee9a5390e82 },

     /*
     .e = 108,
     .MEMORY_LOG_SIZE = 20,
     .ALPHA = 2.25,
     .BETA = 10.,
     .GAMMA = 20.,
     .PRNG_SEED = 1337,
     .delta = 0,
            .jinv = { 0x6BE8246542864A37, 0x11E362B039D68837, 0x9BC7A67DEEC54A2E, 0x4E6B64B48B589AA2, 0x4A904043E41FA41C, 0x61B809F34CAEF5E1, 0x44A755CAA245, 0xC739FAE5D5743D2C, 0x96F1175A33853137, 0x5FDED023029DBBE5, 0x14755F7F49BCAAA1, 0x4FD0FA75FD3CF48D, 0xC24C83D46D574891, 0x7F2CD7F534C3 },
            .E = {
                {
                .a24 = { 0xE858, 0x0, 0x0, 0x721FE809F8000000, 0xB00349F6AB3F59A9, 0xD264A8A8BEEE8219, 0x1D9DD4F7A5DB5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
                .xp = { 0x88AEA34159076AB3, 0xA5A5CB1A903DA770, 0x16B33C999300B977, 0xAA7A6F7A88CC0624, 0xAC4EF004B7D84E09, 0x79475FE0A608CB5E, 0x1E8C483F1256F, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
                .xq = { 0x3BF57331DB10FDB2, 0x936F70C4C619C7B7, 0x3D4081EE4B1462B7, 0x10E9214AB8DC1FF4, 0x35B8DB8454A82F1C, 0x706C9F7736811583, 0xBF6E146508AA, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
                .xpq = { 0xE94179134A7F2DE2, 0x6673CCEC7252249, 0xC79527DE95BA4360, 0xBAC76DFBDD10CE6C, 0x3CB9CA27612F8DF9, 0xBD318A5642CD294B, 0x185034C4A42D4, 0x5BD15E78CE28EC15, 0x98241F00AA5B8A13, 0x50FCBE39A343C4EF, 0x9C76C679526A6D11, 0xF7D3C1F044C57564, 0x3FEC6B54113419CD, 0x1FC45E1431738 },
                },
                {
                .a24 = { 0x605AB9CC9FE6D6C7, 0xA678D2205581290F, 0xDA9DB6845C7FF497, 0x50E7879BBD30A0D7, 0x6CA3F575A8D37E0, 0x1DB395D4FF2CF06C, 0xFF7843A8619E, 0x4B5DD216D07D18F5, 0x4E859F9552292A7, 0xA5286F0ABA23D855, 0xEA106E29AB43E8CC, 0xDDE55AE059796CB5, 0xF38271742C3F4D60, 0x216CD896D147E },
                .xp = { 0x8ACB2783EDA6DC9D, 0xEB56FB79524430BE, 0x208FDFEB6C1FD415, 0xDCC2151B31FDE4B1, 0x486A4DA86559C4, 0xC5EFB5657A70D23E, 0xF3CB72FA9794, 0x64159D2D589F624F, 0x7A4608160FB91307, 0x4A6B884DD9FADEA7, 0xB6F8DD1D2550239B, 0x5EA96959DDF5842F, 0x9C7D7A752F62F5B3, 0x502789C15A1F },
                .xq = { 0x47508122C6E97FD0, 0x19DE7CCF3CAA0F6, 0xC7582D8790F47019, 0x8985C3D827BB6082, 0x66357E0A90FFA2CF, 0x62FD9BE26798AC17, 0x10F698EF0D685, 0xD27C4F3371BFAA23, 0x7FEE588FFF7CBFC7, 0xA676C1D8A4DA3538, 0x34D1CF8255FC237C, 0xB43D2E5596CFCB8C, 0x3BB14A9F8E79A87D, 0x140C5E7827394 },
                .xpq = { 0xF14246746D3FA1A4, 0x405E0AD8A0BB8679, 0x114A7CADA7AB5622, 0xEBADA4555948A5AE, 0x9AAEEA436BECC7EA, 0xFDB141A820D06FD3, 0x20B51F1D11838, 0xE6401E60DE1457A8, 0xB9F23BE75F5345D4, 0x870F9FA720D2BE41, 0x2E83BCBABE5DD1F4, 0xFB51FF83BE75B656, 0x29E127B33C211135, 0x85F1D1056A67 },
         */
         }};

#elif defined(P503)

instance_t insts_stats = {
     .MODULUS = "p_250_159",
     .e = 20,
     .MEMORY_LOG_SIZE = 10,
     .ALPHA = 2.25,
     .BETA = 10.,
     .GAMMA = 20.,
     .PRNG_SEED = 1337,
     .delta = 0,
        .jinv = { 0x7B1069A317ABE17, 0xD91E624162795665, 0xE14F56FC672B7592, 0x978ABDE4980EC7EF, 0x9ED12136EEE32C99, 0x82E4718671B5C07C, 0x4F927E64BD66576D, 0x3819C752B9B836, 0xD8900FEAC51ECF84, 0xD00F00AD8627F25F, 0x8C00FE1D0554977F, 0x1FD05E674D34DE23, 0x4FF7CCD540EAD14B, 0xC52124019168FBF6, 0x9EA3B1CB7335ACBE, 0x1299837E02486E },
        .E = {
            {
            .a24 = { 0x7F3, 0x0, 0x0, 0xBC00000000000000, 0xB48DD9032BABBDC8, 0x87354452517EE94B, 0xB55528D05AECDDB4, 0xD90684A9D9488, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xp = { 0x5F7B8F609B6ED6B9, 0xF7FE076EC21D87D8, 0x9BDF915FD7CF7340, 0xF241F5E78D0CD529, 0x427F1BBED7A40E55, 0x3528A795A020D25D, 0xDD3CF675A20860B4, 0x31C335B713C458, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xq = { 0xAB55946EB560C6B3, 0xE4AB7B6346F9EF66, 0xAAB3ACE51D6D3396, 0x5C66E0FF8E474723, 0xF76FADA339A7C848, 0x25E89F5E6BA1E294, 0xD3CC76DC20CFD3F6, 0x3621AF63A7851F, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xpq = { 0x649C5F34B602F2C, 0xB44A3DE14B6CA60A, 0x9A83D8FB5F4017E0, 0x1EAD977B3E6AC339, 0x668943879E56962C, 0xE5596B408051972B, 0x63040E44089DD67A, 0xECF7643F3707B, 0x3315609C656CF559, 0xA8EB8A054FF3AFF1, 0x26595B66D4670388, 0x16B21121D2EE95E, 0xEB9F0A72C0180CCA, 0xBC809BFAF5A2F735, 0x66BDBDFC4A632B16, 0x2E1BAEF73B2654 },
            },
            {
            .a24 = { 0x3B304D9DCB1D61C8, 0x6DC797AA6934894A, 0xA9989C2C863307A1, 0x74A43F6A7863C06D, 0x7C7A05C698D7DE67, 0x1ADEED9D5BC42E12, 0xED92B56E55CA6E9C, 0x3FE08DC161F3F9, 0xC554D8320E773AAB, 0x1E736B0AA5B188AB, 0x2F5F8BC0FE9A675D, 0xFAD09FD3BE0164CE, 0xA1D95BF6DFF00E57, 0x7969C50AB2D53DEC, 0x645E028FF74B2572, 0x24DCC3CAF74266 },
            .xp = { 0xE728BD5EA5FE0D83, 0x8DB2E1A99632C4C2, 0x10DE9161DF97B6C2, 0x65A584E64B08B543, 0xBE9FF0B715B9AD77, 0xEE7E643CD82CCA8D, 0xD22A68FACB94B6C5, 0x35E9E96570C915, 0x87D4F9933E7C6AA4, 0x53841A25FB26062B, 0x24186378F00CED1D, 0x66471562002C6441, 0x1926D006C3A8D29F, 0xB249153617AB80FA, 0x8064EB3DE83A177E, 0x7835C3CDFFD4 },
            .xq = { 0xD648E5E5FF72556F, 0x41764F50A1ACC559, 0xDE2A8EF09B23CE6A, 0xC96BE152711A121C, 0xB4E22EA7E0D14CF7, 0x5B47E45F69785A3F, 0x55CFC14617EFABB8, 0x3D140EA6EABDE0, 0xA51B2740A983362D, 0xBA54FEEBDDDC3988, 0x2BA411FBD3596527, 0xAE59E4BC4E368455, 0x9B163A5B2463A226, 0xB9317F79F53BB37, 0x2EFEDA29034CAA3B, 0x2EADC006F3432B },
            .xpq = { 0x7149C0B6F17BDBBE, 0xC622DD4DB9F1FDB7, 0xB2D886B92A57D7F4, 0x5A477C6736BBA881, 0xFA93DB5F82A0E15F, 0xE95DF01169D23D40, 0xC10BBFA15843305C, 0x1CB548CD883868, 0x8646A208B9FDEF40, 0x1DDB08E2A44F873B, 0xB30523F5728641F8, 0x84CF5815FBB3507, 0x763052A0F45BFF94, 0x5BF9A0ED7CBA5D86, 0x15C6B830B25D081C, 0x2F1E00CA52B2E2 },
     /*
        .e = 125,
        .MEMORY_LOG_SIZE = 20,
        .ALPHA = 2.25,
        .BETA = 10.,
        .GAMMA = 20.,
        .PRNG_SEED = 1337,
        .delta = 0,
        .jinv = { 0xD1BBAC82E07FCF9F, 0xC151904789747C92, 0x84BDA7C0C782288, 0x2A2405C21B4CFCAE, 0xBB553805D26928EF, 0x44421DFC69DABEEF, 0xF5D5B3A7E069D6A0, 0xE5327B4BF9856, 0xE644766AB4B75D9C, 0xCF784FD50103D479, 0x559C4873A4C622D9, 0x8167F2825D3F4281, 0x3C765F7405392B4C, 0xB78FE20888EB41B5, 0x5C0382BF27FCCD4F, 0x2DCB77F590E42D },
        .E = {
            {
            .a24 = { 0x7F3, 0x0, 0x0, 0xBC00000000000000, 0xB48DD9032BABBDC8, 0x87354452517EE94B, 0xB55528D05AECDDB4, 0xD90684A9D9488, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xp = { 0x57E4C3DC3C34FEC8, 0x5E7CBAB2145B996C, 0x402A9B7C60936E25, 0x43326751EE7606F4, 0xF693342F55CAEDDB, 0x37E8E694B55B1FAA, 0x8EEE88AA76D608F7, 0x293343D3ADF524, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xq = { 0x9352C28B24ADA4D4, 0xAEC60590945E55A6, 0xBD4A119EF6790C1B, 0xD7001347C613EB27, 0x46133F7DE1BB3ACB, 0x9B5DFDA6CC5D337B, 0xD9E0C1CA6634FF5, 0x11D4EDBDC672, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 },
            .xpq = { 0x72C717020C264CB7, 0xA08F39B12103D484, 0x3D0E21B460D44442, 0x3A2FA6383A13852C, 0x33018A8CA21B1E51, 0xEBCA5B9EA15368D1, 0xB54F9CCB574EE719, 0x3FD59DD4E0BF67, 0x6AD7BCB41A552127, 0x4251FC98220CC58B, 0x3ADEEB81F7B58347, 0x4F7575D16C4E89CA, 0x6868869F9A83D150, 0xAA72BB30B7A060AC, 0x231A55962C1EDF73, 0xC4EC27B3868EC },
            },
            {
            .a24 = { 0xA711D45016D90FB8, 0xDD6B7E13054EAC96, 0x23CA03807E382410, 0x438C4B07CC01E737, 0x98AEA0C2F01D033F, 0xE6886B03A3A35E2B, 0x23E37EBFD0767DBD, 0x2C3AFA43C9E121, 0xEEFE0052B9C641BE, 0x37E954FB1A097EFF, 0x8063AEE039256EB3, 0xDA1DB94B54B738B4, 0xDD76C657B4765B62, 0xDD7559A97A102398, 0xCC5FF4C6AD3A20EE, 0x21273EB592A410 },
            .xp = { 0xFD5108C0750E4C98, 0xB392593FEAC4ABD1, 0x78DC7E5250CB4F79, 0x164C6DD9F18BBE2E, 0xC18CD8E1509B31D2, 0xDB1EB9A72CFB286D, 0x38808257D47E18C0, 0x27923D6FA3BDE5, 0x89562D196F90D9E1, 0xAA913167BA6D0217, 0x901D45D257C11EF0, 0x9B993E351BCC4ECC, 0x14E0C56DC28C7133, 0x145731EBE82AA136, 0x492CB86518144062, 0x55D8BC06ECF3A },
            .xq = { 0x208AAAF822FB8686, 0x9C965534F2A37DEB, 0x96B74E06CAC8478B, 0xDC2DB196652EA4C3, 0xED6F47591296908A, 0x9559EF96D9BD935C, 0xAD56849C57460708, 0x3077E8F0ECF6B9, 0x1543281D059F3968, 0x3BC61240E67BF24E, 0x131D9E0031F5E382, 0x27B580294CCB4500, 0x36E9587AA7A0F1CF, 0x8446C032CB45A7B5, 0x622F6CF86F8E6297, 0x32B330C44BCBB6 },
            .xpq = { 0x4A50D61DD7A18413, 0x78B7F8A741F6376C, 0x3DF47D93DDD1C562, 0x6FE4C201BA66E88B, 0xF2AB463F105394D1, 0xEBFC8A07752CE227, 0x716FCB79A65CB7B5, 0x205D5DD052E0F3, 0x6391D7ACA3B8E247, 0xB1AD23CC667A3D23, 0x9BE929281FAA5F59, 0x2E12AFDB9513076D, 0x38371CD7E35CE3EB, 0xBD310552D7264F4C, 0x9DFE2A28C07EEE50, 0x33B3BEEAC2E488 },
         */   
         }}};
#endif
