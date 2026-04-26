//
//  NewClientSAPRepository.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//

class NewClientRegisterSAPRepository {
    private let api: AlphaAPIService
    
    init(api: AlphaAPIService = .shared) {
        self.api = api
    }
    
    func registrarClienteSAP(base: String, clienteRequest: NewClientSAPRequest) async -> Result<NewClientSAPResponse, Error> {
        do {
            let response = try await api.crearClienteSAP(db: base, body: clienteRequest)
            return .success(response)
        } catch {
            return .failure(error)
        }
        
    }
    
}
/*
 class NewClientRegisterSAPRepository(private val iSAP_AlphaAPI: ISAP_AlphaAPI) {
     suspend fun registrarClienteSAP(base: String, clienteRequest: NewClientSAPRequest): Result<NewClientSAPResponse>{
         return try{
             val response = iSAP_AlphaAPI.crearClienteSAP(base, clienteRequest).awaitResponse()
             if (response.isSuccessful) {
                 Result.success(response.body()!!)
             } else {
                 throw Exception("Error ${response.code()}")
             }
         }catch (e: HttpException){
             throw Exception("Error ${e.code()}")
         }
     }
 }
 */
