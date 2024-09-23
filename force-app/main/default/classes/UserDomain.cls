public class UserDomain {
    public static User obterUsuarioPorId(Id idUsuario) {
        List<User> usuarios = UserSelector.obterUsuariosPorIds(new Set<Id>{ idUsuario });

        return usuarios.isEmpty() ? new User() : usuarios.get(0);
    }
}