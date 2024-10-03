public class CampaignDto {
    public String name;
    public Id id;
    public String type;
    public String status;
    public Boolean isActive;

    public CampaignDto(Campaign campaign) {
        this.name = campaign.Name;
        this.id = campaign.Id;
        this.type = campaign.Type;
        this.status = campaign.Status;
        this.isActive = campaign.IsActive;
    }
}