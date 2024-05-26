require 'uri'
require 'net/http'
require 'json'
require 'csv'

def get_api_call(auth_token, end_point)
    
    uri = URI.parse(end_point)
    
    headers = {
        'Authorization' => "Bearer #{auth_token}",
        'accept' => 'application/json'
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri, headers)  
    response = http.request(request)

    case response
    when Net::HTTPSuccess
        data = JSON.parse(response.body)
        return data['data'] 
    else
        puts "GET request failed for endpoint: #{endpoint}"
        puts
        puts "Error code: #{response.code}"
        puts "Error message: #{response.message}"
        puts
        return nil
    end
end

def get_relationships(auth_token)

    get_relationships_end_point = "https://app.parma.ai/api/v1/relationships"
    get_api_call(auth_token, get_relationships_end_point)

end

def get_notes_for_relationship(auth_token, relationship_id)

    get_notes_end_point = "https://app.parma.ai/api/v1/relationships/#{relationship_id}/notes"
    get_api_call(auth_token, get_notes_end_point)

end

def main
    auth_token = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOjUsImp0aSI6Mjk2LCJpYXQiOjE3MTY2MTU5NDQsImV4cCI6MjAzMjE0ODc0NH0.zXDFLSmytlR_TgKhj73i744XnelwcqoT9YrhOvtfEMk'

    # Fetch all relationships
    relationships = get_relationships(auth_token)

    if relationships
        # open csv file
        CSV.open("notes_and_relationships.csv", "wb") do |csv|
        
            csv << ["Note ID", "Note Body", "Note Date", "Relationship ID", "Relationship Name", ]

            # Iterate over each relationship to fetch notes
            relationships.each do |relationship|

                relationship_id = relationship['id']
                relationship_name = relationship['name']

                notes = get_notes_for_relationship(auth_token, relationship_id)
                
                if notes
                    # iterate over each note
                    notes.each do |note|
                        csv << [note['id'], note['body'], note['datetime'], relationship_id, relationship_name]
                    end

                else
                    # If there are no notes, mark fields of notes as empty fields
                    csv << [nil, nil, nil, relationship_id, relationship_name]
                end
            end
        end
        puts "Success - Data has been written in the file named notes_and_relationships.csv"
    else
        puts "Relationship not found !!"
    end
end

main
